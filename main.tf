# Provider configuration with subscription and tenant details
provider "azurerm" {
  features {}

  # Specify the subscription ID
  subscription_id = "your subscription_id"
  
  # Optional: Specify tenant ID if needed (can be skipped if using default tenant)
  tenant_id       = "your tenant_id"
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "example-rg"
  location = "East US"
}

# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = "exampleacr1234"  # Must be globally unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
}

# Create Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "example-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "exampleaks"

  # Configure the default node pool
  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  # Use System Assigned Identity
  identity {
    type = "SystemAssigned"
  }

  # Configure Network Profile
  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.0.2.10"
    service_cidr   = "10.0.2.0/24"
  }

  depends_on = [azurerm_subnet.subnet]
}
