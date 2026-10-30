
resource "azurerm_storage_account" "lake" {
  name                     = "alaa0netflixdata"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = "centralus"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true

  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"

  tags = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "layers" {
  for_each              = toset(local.layers)
  name                  = each.key
  storage_account_id    = azurerm_storage_account.lake.id
  container_access_type = "private"
}
