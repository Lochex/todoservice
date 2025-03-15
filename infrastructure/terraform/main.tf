provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

# Create a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "todo-aks-rg"
  location = "East US"
}

# Create an Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = "todoaksacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Create an AKS Cluster with a single, small node to minimize cost
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "todo-aks-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "todoaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"  # A low‑cost option; you may consider "Standard_B1ms" if available
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_postgresql_server" "db" {
  name                = "todo-postgres"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  administrator_login          = "dbadmin"
  administrator_login_password = "YourSecurePassword123!"
  version                      = "11"
  sku_name                     = "B_Gen5_1"       # A basic SKU for single-server; adjust as needed.
  storage_mb                   = 5120             # Minimum storage for demo purposes.
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_database" "tododb" {
  name                = "tododb"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.db.name
  charset             = "UTF8"
  collation           = "en_US.utf8"
}