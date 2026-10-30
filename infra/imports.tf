locals {
  sub = "/subscriptions/d92cfcda-eb73-45ff-b299-a53879d3a113/resourceGroups/rg-netflix-adf-dev/providers"
}

import {
  to = azurerm_storage_account.lake
  id = "${local.sub}/Microsoft.Storage/storageAccounts/alaa0netflixdata"
}

import {
  to = azurerm_storage_container.layers["landing"]
  id = "${local.sub}/Microsoft.Storage/storageAccounts/alaa0netflixdata/blobServices/default/containers/landing"
}

import {
  to = azurerm_storage_container.layers["bronze"]
  id = "${local.sub}/Microsoft.Storage/storageAccounts/alaa0netflixdata/blobServices/default/containers/bronze"
}

import {
  to = azurerm_storage_container.layers["silver"]
  id = "${local.sub}/Microsoft.Storage/storageAccounts/alaa0netflixdata/blobServices/default/containers/silver"
}

import {
  to = azurerm_storage_container.layers["gold"]
  id = "${local.sub}/Microsoft.Storage/storageAccounts/alaa0netflixdata/blobServices/default/containers/gold"
}

import {
  to = azurerm_storage_container.layers["config"]
  id = "${local.sub}/Microsoft.Storage/storageAccounts/alaa0netflixdata/blobServices/default/containers/config"
}

import {
  to = azurerm_key_vault.main
  id = "${local.sub}/Microsoft.KeyVault/vaults/kv-netflix-alaa"
}

import {
  to = azurerm_data_factory.dev
  id = "${local.sub}/Microsoft.DataFactory/factories/alaaNetflixDF"
}

import {
  to = azurerm_data_factory.prod
  id = "${local.sub}/Microsoft.DataFactory/factories/alaaNetflixDF-prod"
}