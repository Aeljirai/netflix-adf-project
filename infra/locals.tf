locals {
  common_tags = {
    environment = "dev"
    owner       = "Alae Eddine El Jirari"
    project     = "netflix-movielens"
    managed_by  = "terraform"
  }

  layers = ["landing", "bronze", "silver", "gold", "config"]
}