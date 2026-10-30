
resource "azurerm_data_factory" "dev" {
  name                = "alaaNetflixDF"
  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus"

  identity {
    type = "SystemAssigned"
  }

  github_configuration {
    account_name       = "aeljirai"
    repository_name    = "netflix-adf-project"
    branch_name        = "main"
    root_folder        = "/adf/"
    git_url            = "https://github.com"
    publishing_enabled = true
  }

  tags = local.common_tags
}

resource "azurerm_data_factory" "prod" {
  name                = "alaaNetflixDF-prod"
  resource_group_name = azurerm_resource_group.main.name
  location            = "centralus"

  identity {
    type = "SystemAssigned"
  }

  tags = merge(local.common_tags, { environment = "prod" })
}
