# Key Vault name (falls back to provided existing name when not creating)
output "kv_name" {
  value       = var.m_create_keyvault ? azurerm_key_vault.keyvault[0].name : var.m_existing_kv_name
  description = "Name of the Key Vault"
}

# Key Vault ID (returns existing KV id when not creating)
output "kv_id" {
  value       = var.m_create_keyvault ? azurerm_key_vault.keyvault[0].id : var.m_existing_kv_id
  description = "Resource ID of the Key Vault"
}

# Key Vault URI (only available when the KV is created by this module, unless you add a data lookup)
output "kv_vault_uri" {
  value       = var.m_create_keyvault ? azurerm_key_vault.keyvault[0].vault_uri : null
  description = "The URI of the Key Vault, used for operations on keys and secrets"
}

# Access policy (main / deploy user)
output "kv_main_access_policy_id" {
  value       = var.m_enable_main_access_policy ? azurerm_key_vault_access_policy.kv_main_access_policy[0].id : null
  description = "Access Policy ID for the current deploy user"
}

# Certificate-related outputs
output "kv_certificate_id" {
  value       = var.m_generate_key_vault_certificate ? azurerm_key_vault_certificate.certificate[0].id : null
  description = "Key Vault Certificate ID"
}

output "kv_certificate_secret_id" {
  value       = var.m_generate_key_vault_certificate ? azurerm_key_vault_certificate.certificate[0].secret_id : null
  description = "ID of the associated Key Vault Secret"
}

output "kv_certificate_version" {
  value       = var.m_generate_key_vault_certificate ? azurerm_key_vault_certificate.certificate[0].version : null
  description = "Current version of the Key Vault Certificate"
}

output "kv_certificate_versionless_id" {
  value       = var.m_generate_key_vault_certificate ? azurerm_key_vault_certificate.certificate[0].versionless_id : null
  description = "Base (versionless) ID of the Key Vault Certificate"
}

output "kv_certificate_data" {
  value       = var.m_generate_key_vault_certificate ? azurerm_key_vault_certificate.certificate[0].certificate_data : null
  description = "Raw Key Vault Certificate data as a hexadecimal string"
}

output "kv_cert_versionless_secret_id" {
  value       = var.m_generate_key_vault_certificate ? azurerm_key_vault_certificate.certificate[0].versionless_secret_id : null
  description = "Versionless secret ID of the certificate"
}

output "kv_certificate_data_base64" {
  value       = var.m_generate_key_vault_certificate ? azurerm_key_vault_certificate.certificate[0].certificate_data_base64 : null
  description = "Base64-encoded Key Vault Certificate data"
}

output "kv_certificate_thumbprint" {
  value       = (var.m_enable_x509_cert_properties && var.m_generate_key_vault_certificate) ? azurerm_key_vault_certificate.certificate[0].thumbprint : null
  description = "X509 thumbprint of the Key Vault Certificate as a hexadecimal string"
}

# Certificate issuer
output "kv_certificate_issuer_name" {
  value       = var.m_to_issue_certificate ? azurerm_key_vault_certificate_issuer.kv_cert_issuer[0].name : null
  description = "Name of the Key Vault Certificate Issuer"
}

output "kv_certificate_issuer_id" {
  value       = var.m_to_issue_certificate ? azurerm_key_vault_certificate_issuer.kv_cert_issuer[0].id : null
  description = "ID of the Key Vault Certificate Issuer"
}

# Access policy IDs
output "kv_access_policy_main_id" {
  value       = var.m_enable_main_access_policy ? azurerm_key_vault_access_policy.kv_main_access_policy[0].id : null
  description = "Key Vault Access Policy ID of the main user"
}

output "kv_custom_access_policy_ids" {
  value = tomap({
    for k, accesspolicy in azurerm_key_vault_access_policy.kv_access_policy : k => accesspolicy.id
  })
  description = "Map of custom Key Vault access policy IDs"
}

# Key IDs
output "kv_key_ids" {
  value = tomap({
    for k, key in azurerm_key_vault_key.az_key_vault_key : k => key.id
  })
  description = "Map of Key Vault key IDs"
}

# Secret IDs and names
output "kv_secret_ids" {
  value = tomap({
    for k, secret in azurerm_key_vault_secret.az_kv_secret : k => secret.id
  })
  description = "Map of Key Vault secret IDs"
}

output "kv_secret_names" {
  value = tomap({
    for k, secret in azurerm_key_vault_secret.az_kv_secret : k => secret.name
  })
  description = "Map of Key Vault secret names"
}
