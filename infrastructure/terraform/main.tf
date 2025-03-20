provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

# Create a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "todo-vnet"
  address_space       = ["10.111.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# # Public IP for the NAT Gateway
# resource "azurerm_public_ip" "nat_gateway_ip" {
#   name                = "aks-nat-ip"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# # NAT Gateway and associate the public IP
# resource "azurerm_nat_gateway" "aks_nat_gateway" {
#   name                = "aks-nat-gateway"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   sku_name            = "Standard"
# }

# resource "azurerm_nat_gateway_public_ip_association" "example" {
#   nat_gateway_id       = azurerm_nat_gateway.aks_nat_gateway.id
#   public_ip_address_id = azurerm_public_ip.nat_gateway_ip.id
# }

# Subnet for AKS and private endpoints
resource "azurerm_subnet" "subnet" {
  name                 = "todo-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.111.1.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}

# resource "azurerm_subnet_nat_gateway_association" "example" {
#   subnet_id      = azurerm_subnet.subnet.id
#   nat_gateway_id = azurerm_nat_gateway.aks_nat_gateway.id
# }

# Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
}

# AKS Cluster with a single, small node
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "todoaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s" 
    vnet_subnet_id = azurerm_subnet.subnet.id
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
  sku_name                     = "GP_Gen5_2"       # A basic SKU for single-server; adjust as needed.
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
  collation           = "English_United States.1252"
}

# Firewall rule to allow traffic from the AKS subnet
resource "azurerm_postgresql_firewall_rule" "allow_aks" {
  name                = "AllowAKSSubnet"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.db.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# # Private DNS Zone for PostgreSQL
# resource "azurerm_private_dns_zone" "postgres_dns_zone" {
#   name                = "privatelink.postgres.database.azure.com"
#   resource_group_name = azurerm_resource_group.rg.name
# }

# # Link the VNet to the Private DNS Zone
# resource "azurerm_private_dns_zone_virtual_network_link" "postgres_dns_link" {
#   name                  = "todo-postgres-dns-link"
#   resource_group_name   = azurerm_resource_group.rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.postgres_dns_zone.name
#   virtual_network_id    = azurerm_virtual_network.vnet.id
#   registration_enabled  = true
# }

# # Private Endpoint for PostgreSQL
# resource "azurerm_private_endpoint" "postgres_private_endpoint" {
#   name                = "todo-postgres-pe"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   subnet_id           = azurerm_subnet.subnet.id

#   private_service_connection {
#     name                           = "todo-postgres-psc"
#     private_connection_resource_id = azurerm_postgresql_server.db.id
#     is_manual_connection           = false
#     # The subresource name for PostgreSQL Single Server is often "postgresqlServer"
#     subresource_names              = ["postgresqlServer"]
#   }
#   private_dns_zone_group {
#     name                 = "postgresql-dns-zone-group"
#     private_dns_zone_ids = [azurerm_private_dns_zone.postgres_dns_zone.id]
#   }
# }
