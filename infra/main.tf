# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "/subscriptions/d92cfcda-eb73-45ff-b299-a53879d3a113/resourceGroups/rg-netflix-adf-dev"



resource "azurerm_resource_group" "main" {
  location   = "westeurope"

  name       = "rg-netflix-adf-dev"
  tags = {
    environment = "dev"
    owner       = "Alae Eddine El Jirari"
    project     = "netflix-movielens"
    managed_by  = "terraform"
  }
}
