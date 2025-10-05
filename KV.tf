locals {
  # Keep instance suffix but without a hyphen (Key Vault names must be alphanumeric only)
  instance_suffix = (var.m_instance_number == null || var.m_instance_number == "") ? "" : var.m_instance_number

  # Build a base KV name, then sanitize: lowercase, alphanumeric only, and trim to 24 chars (KV limit)
  kv_name_base  = format("azr%skv%s%s", var.m_environment_tag, var.m_app_name, local.instance_suffix)
  keyvault_name = substr(lower(regexreplace(local.kv_name_base, "[^0-9a-zA-Z]", "")), 0, 24)

  network                   = var.m_enable_kv_network_firewall_settings ? { dummy_create = true } : {}
  lifetime_action           = var.m_lifetime_action_type == null ? {} : { dummy_create = true }
  x509_cert_properties      = var.m_enable_x509_cert_properties ? { dummy_create = true } : {}
  subject_alternative_names = var.m_enable_alternative_dns_name ? { dummy_create = true } : {}
  cert_admin_issuer         = var.m_enable_cert_admin_issuer ? { dummy_create = true } : {}

  # Resolve the KV ID whether we create a new one or reuse an existing one
  kv_id = var.m_create_keyvault ? azurerm_key_vault.keyvault[0].id : var.m_existing_kv_id
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  # ts:skip=AC_AZURE_0169 need to skip rule - Ensure that logging for Azure KeyVault is Enabled
  count                         = var.m_create_keyvault ? 1 : 0
  name                          = local.keyvault_name
  location                      = var.m_location
  resource_group_name           = var.m_resource_group_name
  enabled_for_disk_encryption   = var.m_kv_enabled_for_disk_encryption
  tenant_id                     = var.m_current_az_client_config ? data.azurerm_client_config.current.tenant_id : var.m_tenant_id
  sku_name                      = lower(var.m_kv_sku_name)
  tags                          = var.m_tags
  soft_delete_retention_days    = var.m_kv_soft_delete_retention_days
  purge_protection_enabled      = var.m_kv_purge_protection_enabled
  public_network_access_enabled = var.m_public_network_access_enabled

  dynamic "network_acls" {
    for_each = local.network
    content {
      bypass                     = var.m_kv_bypass
      default_action             = var.m_kv_default_action
      ip_rules                   = var.m_kv_ip_rules
      virtual_network_subnet_ids = var.m_vnet_subnets_ids
    }
  }
}

# Access Policy to the current deployment user of AAD
resource "azurerm_key_vault_access_policy" "kv_main_access_policy" {
  count                   = var.m_enable_main_access_policy ? 1 : 0
  key_vault_id            = local.kv_id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = data.azurerm_client_config.current.object_id
  key_permissions         = var.m_kv_access_key_permissions
  secret_permissions      = var.m_kv_access_secret_permissions
  certificate_permissions = var.m_kv_access_certificate_permissions
  storage_permissions     = var.m_kv_access_storage_permissions
}

# Access Policies for principals you pass in
resource "azurerm_key_vault_access_policy" "kv_access_policy" {
  for_each                = var.m_kv_access_policy
  key_vault_id            = local.kv_id
  tenant_id               = var.m_app_tenant_id
  object_id               = each.value.resource_principal_id
  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
  certificate_permissions = each.value.certificate_permissions
  storage_permissions     = each.value.storage_permissions
}

resource "azurerm_key_vault_secret" "az_kv_secret" {
  depends_on      = [azurerm_key_vault_access_policy.kv_main_access_policy, azurerm_key_vault_access_policy.kv_access_policy]
  for_each        = var.m_kv_secret
  name            = each.value.name
  value           = each.value.secret_value
  not_before_date = each.value.not_before_date
  expiration_date = each.value.expiration_date
  key_vault_id    = local.kv_id
  tags            = var.m_tags
}

resource "azurerm_key_vault_key" "az_key_vault_key" {
  depends_on      = [azurerm_key_vault_access_policy.kv_main_access_policy, azurerm_key_vault_access_policy.kv_access_policy]
  for_each        = var.m_kv_key
  name            = each.value.name
  key_vault_id    = local.kv_id
  key_type        = each.value.key_type
  key_size        = each.value.key_size
  key_opts        = each.value.key_opts
  not_before_date = each.value.not_before_date
  expiration_date = each.value.expiration_date
  curve           = each.value.curve
  tags            = var.m_tags
}

resource "azurerm_key_vault_certificate" "certificate" {
  depends_on   = [azurerm_key_vault_access_policy.kv_main_access_policy, azurerm_key_vault_access_policy.kv_access_policy]
  count        = var.m_generate_key_vault_certificate ? 1 : 0
  name         = var.m_kv_cert_name
  key_vault_id = local.kv_id

  certificate_policy {
    issuer_parameters {
      name = var.m_kv_cert_issuer_name
    }

    key_properties {
      exportable = var.m_is_exportable
      key_size   = var.m_cert_key_size
      key_type   = var.m_cert_key_type
      reuse_key  = var.m_cert_reuse_key
    }

    dynamic "lifetime_action" {
      for_each = local.lifetime_action
      content {
        action {
          action_type = var.m_lifetime_action_type
        }
        trigger {
          days_before_expiry  = var.m_lifetime_percentage == null ? var.m_trigger_days_before_expiry : null
          lifetime_percentage = var.m_trigger_days_before_expiry == null ? var.m_lifetime_percentage : null
        }
      }
    }

    secret_properties {
      content_type = var.m_cert_secret_content_type
    }

    dynamic "x509_certificate_properties" {
      for_each = local.x509_cert_properties
      content {
        extended_key_usage = var.m_extended_key_usage
        key_usage          = var.m_key_usage
        subject            = var.m_x509_cert_subject
        validity_in_months = var.m_x509_cert_validity_in_months

        dynamic "subject_alternative_names" {
          for_each = local.subject_alternative_names
          content {
            dns_names = var.m_subject_alternative_dns_name
          }
        }
      }
    }
  }
}

resource "azurerm_key_vault_certificate_issuer" "kv_cert_issuer" {
  depends_on    = [azurerm_key_vault_access_policy.kv_main_access_policy, azurerm_key_vault_access_policy.kv_access_policy]
  count         = var.m_to_issue_certificate ? 1 : 0
  name          = var.m_cert_issuer_name
  org_id        = var.m_cert_issuer_org_id
  key_vault_id  = local.kv_id
  provider_name = var.m_cert_issuer_provider_name
  account_id    = var.m_cert_issuer_account_id
  password      = var.m_cert_issuer_password

  dynamic "admin" {
    for_each = local.cert_admin_issuer
    content {
      email_address = var.m_cert_issuer_admin_email_address
      first_name    = var.m_cert_issuer_admin_first_name
      last_name     = var.m_cert_issuer_admin_last_name
      phone         = var.m_cert_issuer_admin_phone
    }
  }
}

# Log Analytics workspace (for Monitor Diagnostic Setting)
data "azurerm_log_analytics_workspace" "az_log_workspace" {
  count               = var.m_enable_kv_monitor_diag ? 1 : 0
  name                = var.m_log_workspace_name
  resource_group_name = var.m_log_workspace_resource_group_name
}

# Monitor Diagnostic Setting
resource "azurerm_monitor_diagnostic_setting" "kv_monitordiagnostic" {
  count                      = var.m_enable_kv_monitor_diag ? 1 : 0
  name                       = var.m_kv_monitor_diagnostic_name
  target_resource_id         = local.kv_id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.az_log_workspace[0].id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

}
