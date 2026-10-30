
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                       = "kv-netflix-alaa"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = "centralus"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  purge_protection_enabled   = false
  soft_delete_retention_days = 90

  tags = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}
