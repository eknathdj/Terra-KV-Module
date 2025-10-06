module "keyvault" {
  source                = "git::https://github.com/module-keyvault.git?ref=v1"
  m_environment_tag     = var.m_environment_tag
  m_app_name            = var.m_app_name
  m_resource_group_name = module.deploy_resource_group.rg_name
  m_location            = var.g_location
  m_instance_number     = var.m_instance_number
  m_tags                = merge(module.common_tags.common_tags, var.m_tags)
}

module "deploy_resource_group" {
  source                = "git::https://github.com/module-resource-group.git?ref=v1"
  m_environment_tag     = var.m_environment_tag
  m_app_name            = var.m_app_name
  m_location            = var.g_location
  m_tags                = merge(module.common_tags.common_tags, var.m_tags)
  m_instance_number     = var.m_instance_number
  m_resource_group_name = var.m_resource_group_name
}
