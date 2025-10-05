########## BEGIN of variables Common / Global for all modules ################

variable "m_app_name" {
  type        = string
  description = "(Required) - Application Name"
}

variable "m_environment_tag" {
  type        = string
  description = <<-EOF
    The environment tag used while labeling provisioned resources. Allowed values:
    - `d` for development
    - `t` for test
    - `q` for qualification
    - `p` for production
    - `m` for mutualized resource
  EOF
  default     = "d"

  validation {
    condition     = contains(["d", "t", "q", "p", "m"], lower(var.m_environment_tag))
    error_message = "Unsupported environment tag specified. Supported values: 'd','t','q','p','m'."
  }
}


variable "m_instance_number" {
  type        = string
  description = "(Optional) - A unique instance number for the resource; helps when creating multiples."
  default     = null
}

variable "m_resource_group_name" {
  type        = string
  description = "(Required) - Resource Group where the Key Vault will be created (or where the existing KV lives)."
}

variable "m_location" {
  type        = string
  description = "(Required) - Azure region where resources should be deployed"
  default     = "West Europe"
}

variable "m_tags" {
  type        = map(string)
  description = "(Optional) - Common tags to apply to resources"
  default     = {}
}

variable "m_create_keyvault" {
  type        = bool
  description = "(Optional) - Set true to create a new Key Vault; false to reuse an existing one"
  default     = true
}

variable "m_kv_enabled_for_disk_encryption" {
  type        = bool
  description = "(Optional) - Allow the Key Vault to be used for disk encryption (Azure Disk Encryption)"
  default     = true
}

variable "m_current_az_client_config" {
  type        = bool
  description = "(Optional) - If true, tenant_id is taken from the current azurerm client config"
  default     = true
}

variable "m_tenant_id" {
  type        = string
  description = "(Optional) - AAD Tenant ID to use if not using current client config"
  default     = null
}

variable "m_app_tenant_id" {
  type        = string
  description = "(Optional) - Tenant ID for app/managed identity principals used in access policies"
  default     = null
}

variable "m_kv_sku_name" {
  type        = string
  description = "(Optional) - Key Vault SKU name (standard or premium)"
  default     = "standard"
}

variable "m_kv_soft_delete_retention_days" {
  type        = number
  description = "(Optional) - Number of days to retain soft-deleted items (7–90)"
  default     = 90
}

variable "m_kv_purge_protection_enabled" {
  type        = bool
  description = "(Optional) - Enable purge protection on the Key Vault?"
  default     = true
}

variable "m_enable_kv_network_firewall_settings" {
  type        = bool
  description = "(Optional) - Enable Key Vault network ACLs"
  default     = false
}

variable "m_kv_bypass" {
  type        = string
  description = "(Optional) - Traffic that can bypass network rules (e.g., AzureServices, None)"
  default     = null
}

variable "m_kv_default_action" {
  type        = string
  description = "(Optional) - Default action when no network rules match (Allow or Deny)"
  default     = "Deny"
}

variable "m_kv_ip_rules" {
  type        = list(string)
  description = "(Optional) - List of IPs/CIDR blocks allowed to access the Key Vault"
  default     = []
}

variable "m_vnet_subnets_ids" {
  type        = list(string)
  description = "(Optional) - Subnet IDs allowed to access the Key Vault"
  default     = []
}

variable "m_enable_main_access_policy" {
  type        = bool
  description = "(Optional) - Enable main access policy for the current deployment user"
  default     = false
}

variable "m_existing_kv_name" {
  type        = string
  description = "(Optional) - Name of an existing Key Vault when m_create_keyvault = false"
  default     = null
}

# New: used when reusing an existing KV (to provide the resource ID directly)
variable "m_existing_kv_id" {
  type        = string
  description = "(Optional) - Resource ID of an existing Key Vault when m_create_keyvault = false"
  default     = null
}

variable "m_kv_access_key_permissions" {
  type        = list(string)
  description = "(Optional) - Default key permissions for the main access policy"
  default     = ["Get", "List", "Create", "Update", "Verify", "Recover", "Delete"]
}

variable "m_kv_access_secret_permissions" {
  type        = list(string)
  description = "(Optional) - Default secret permissions for the main access policy"
  default     = ["Get", "List", "Set", "Recover", "Delete"]
}

variable "m_kv_access_certificate_permissions" {
  type        = list(string)
  description = "(Optional) - Default certificate permissions for the main access policy"
  default     = ["Get", "Delete"]
}

variable "m_kv_access_storage_permissions" {
  type        = list(string)
  description = "(Optional) - Default storage permissions for the main access policy"
  default     = ["Get", "Delete"]
}

variable "m_kv_access_policy" {
  type = map(object({
    resource_principal_id   = string
    key_permissions         = list(string)
    secret_permissions      = list(string)
    certificate_permissions = list(string)
    storage_permissions     = list(string)
  }))
  description = <<-ACCESS_POLICY
    (Optional) - Map of additional Key Vault access policies keyed by a logical name.
    Each item specifies the principal's object_id and lists of permissions.
  ACCESS_POLICY
  default     = {}
}

variable "m_kv_secret" {
  type = map(object({
    name            = string
    secret_value    = string
    not_before_date = string
    expiration_date = string
  }))
  description = <<-KV_SECRET
    (Optional) - Map of Key Vault secrets to create.
  KV_SECRET
  default     = {}
}

variable "m_kv_key" {
  type = map(object({
    name            = string
    not_before_date = string
    expiration_date = string
    key_size        = number
    key_type        = string
    key_opts        = list(string)
    curve           = string
  }))
  description = <<-KV_KEY
    (Optional) - Map of Key Vault keys to create.
  KV_KEY
  default     = {}
}

variable "m_generate_key_vault_certificate" {
  type        = bool
  description = "(Optional) - Set true to generate a Key Vault certificate"
  default     = false
}

variable "m_kv_cert_name" {
  type        = string
  description = "(Optional) - Name of the Key Vault certificate"
  default     = ""
}

variable "m_kv_cert_issuer_name" {
  type        = string
  description = <<-CERT_ISSUER_NAME
    (Optional) - Certificate issuer name. Examples: Self, Unknown.
  CERT_ISSUER_NAME
  default     = "Self"
}

variable "m_is_exportable" {
  type        = bool
  description = "(Optional) - Whether the private key is exportable"
  default     = true
}

variable "m_cert_key_size" {
  type        = number
  description = <<-CERT_KEY_SIZE
    (Optional) - Key size in bits (e.g., 2048/3072/4096 for RSA; 256/384/521 for EC).
  CERT_KEY_SIZE
  default     = 2048
}

variable "m_cert_key_type" {
  type        = string
  description = "(Optional) - Key type for the certificate (e.g., RSA or EC)"
  default     = "RSA"
}

variable "m_cert_reuse_key" {
  type        = bool
  description = "(Optional) - Whether to reuse the key on renewal"
  default     = null
}

# Action / lifetime
variable "m_lifetime_action_type" {
  type        = string
  description = "(Optional) - Action type when lifetime trigger fires (e.g., AutoRenew, EmailContacts)"
  default     = null
}

variable "m_trigger_days_before_expiry" {
  type        = number
  description = "(Optional) - Days before expiry when the trigger should run"
  default     = null
}

variable "m_lifetime_percentage" {
  type        = number
  description = "(Optional) - Percentage of lifetime when the trigger should run"
  default     = null
}

variable "m_cert_secret_content_type" {
  type        = string
  description = "(Optional) - Certificate content type (application/x-pkcs12 for PFX or application/x-pem-file for PEM)"
  default     = "application/x-pkcs12"
}

variable "m_enable_x509_cert_properties" {
  type        = bool
  description = "(Optional) - Enable x509_certificate_properties block"
  default     = false
}

variable "m_extended_key_usage" {
  type        = list(string)
  description = "(Optional) - Extended/Enhanced Key Usages OIDs"
  default     = []
}

variable "m_key_usage" {
  type        = list(string)
  description = "(Optional) - Key usages (case-sensitive): cRLSign, dataEncipherment, decipherOnly, digitalSignature, encipherOnly, keyAgreement, keyCertSign, keyEncipherment, nonRepudiation"
  default     = []
}

variable "m_subject_alternative_dns_name" {
  type        = list(string)
  description = "(Optional) - Alternative DNS names (FQDNs)"
  default     = []
}

variable "m_x509_cert_subject" {
  type        = string
  description = "(Optional) - Subject of the certificate"
  default     = ""
}

variable "m_x509_cert_validity_in_months" {
  type        = number
  description = "(Optional) - Certificate validity period in months"
  default     = 30
}

variable "m_enable_alternative_dns_name" {
  type        = bool
  description = "(Optional) - Enable subject alternative names in the certificate"
  default     = false
}

# Certificate Issuer
variable "m_to_issue_certificate" {
  type        = bool
  description = "(Optional) - Set true to configure a certificate issuer"
  default     = false
}

variable "m_cert_issuer_name" {
  type        = string
  description = "(Optional) - Name to use for this Key Vault certificate issuer"
  default     = null
}

variable "m_cert_issuer_org_id" {
  type        = string
  description = "(Optional) - Organization ID provided to the issuer"
  default     = null
}

variable "m_cert_issuer_provider_name" {
  type        = string
  description = "(Optional) - Third-party issuer name (e.g., DigiCert, GlobalSign, OneCertV2-PrivateCA, OneCertV2-PublicCA, SslAdminV2)"
  default     = null
}

variable "m_cert_issuer_account_id" {
  type        = string
  description = "(Optional) - Account number with the third-party certificate issuer"
  default     = null
}

variable "m_cert_issuer_password" {
  type        = string
  description = "(Optional) - Password for the issuer account (won't overwrite previous if omitted)"
  default     = null
}

variable "m_enable_cert_admin_issuer" {
  type        = bool
  description = "(Optional) - Set true to configure admin details for the certificate issuer"
  default     = false
}

variable "m_cert_issuer_admin_email_address" {
  type        = string
  description = "(Optional) - Admin email address"
  default     = null
}

variable "m_cert_issuer_admin_first_name" {
  type        = string
  description = "(Optional) - Admin first name"
  default     = null
}

variable "m_cert_issuer_admin_last_name" {
  type        = string
  description = "(Optional) - Admin last name"
  default     = null
}

variable "m_cert_issuer_admin_phone" {
  type        = string
  description = "(Optional) - Admin phone number"
  default     = null
}

# Diagnostics
variable "m_enable_kv_monitor_diag" {
  type        = bool
  description = "(Optional) - Enable a Monitor Diagnostic Setting for the Key Vault"
  default     = false
}

variable "m_log_workspace_name" {
  type        = string
  description = "(Optional) - Log Analytics Workspace name for diagnostics"
  default     = ""
}

variable "m_log_workspace_resource_group_name" {
  type        = string
  description = "(Optional) - Resource Group name of the Log Analytics Workspace"
  default     = ""
}

variable "m_kv_monitor_diagnostic_name" {
  type        = string
  description = "(Optional) - Diagnostic setting name"
  default     = ""
}

variable "m_public_network_access_enabled" {
  type        = bool
  description = "(Optional) - Enable public network access on the Key Vault?"
  default     = false
}
