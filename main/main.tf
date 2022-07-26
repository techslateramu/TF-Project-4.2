data "azurerm_client_config" "current" {}

module "resource_group" {    
  source    = "../modules/resourcegroup"
  rg_name   = var.rg_name
  location  = var.location  
  tags      = var.tags
}

module "key_vault" {    
  source    = "../modules/keyvault"
  depends_on = [ module.resource_group ]
  kv_name   = var.kv_name
  rg_name   = var.rg_name
  location  = var.location  
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
}

module "cosmosdb_account" {    
  source    = "../modules/cosmosdb"
  depends_on = [ module.key_vault ]
  rg_name   = var.rg_name
  location  = var.location  
}

module "key_vault_secret" {
  source              = "../modules/keyvaultsecret"
  depends_on          = [module.key_vault, module.cosmosdb_account]
  key_vault_id        = module.key_vault.key_vault_id
  secret_names = {
    "cosmos-db-primary-key"   = module.cosmosdb_account.primary_key
    "cosmos-db-secondary-key" = module.cosmosdb_account.secondary_key
  }
}







