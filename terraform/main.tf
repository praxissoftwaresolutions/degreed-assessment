data "azurerm_client_config" "current" {}

#### TODO: Modulize and move to separate files for better organization and readability
#### ACR
resource "azurerm_resource_group" "degreed-acr-rg" {
  name     = "degreed-acr-rg"
  location = "eastus"
}

resource "azurerm_container_registry" "degreed-acr" {
  name                = "degreedcontainerregistry"
  resource_group_name = azurerm_resource_group.degreed-acr-rg.name
  location            = azurerm_resource_group.degreed-acr-rg.location
  admin_enabled       = false
  sku                 = "Basic"
}

#### Identities
resource "azurerm_resource_group" "degreed-identity-rg" {
  name     = "degreed-identity-rg"
  location = "eastus"
}

resource "azurerm_user_assigned_identity" "res-0" {
  location            = azurerm_resource_group.degreed-identity-rg.location
  name                = "degreed-mid-api"
  resource_group_name = azurerm_resource_group.degreed-identity-rg.name
  tags                = {}
}

resource "azurerm_user_assigned_identity" "github-actions-identity" {
  location            = azurerm_resource_group.degreed-identity-rg.location
  name                = "github-actions-identity"
  resource_group_name = azurerm_resource_group.degreed-identity-rg.name
  tags                = {}
}

# TODO: Configure the Federated Identity Credential
/* resource "azuread_application_federated_identity_credential" "github-actions-fic" {
  application_id = "/applications/${azurerm_user_assigned_identity.github-actions-identity.principal_id}"
  display_name   = "githubaction"
  description    = "Federated Identity Credentials for GitHub Actions to deploy Azure resources using Terraform"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:praxissoftwaresolutions/degreed-assessment:ref:refs/heads/main"

  depends_on = [azurerm_user_assigned_identity.github-actions-identity]
} */

resource "azurerm_user_assigned_identity" "degreed-cluster-identity" {
  location            = azurerm_resource_group.degreed-identity-rg.location
  name                = "degreed-cluster-identity"
  resource_group_name = azurerm_resource_group.degreed-identity-rg.name
  tags                = {}
}

resource "azurerm_user_assigned_identity" "degreed-cluster-agentpool-identity" {
  location            = azurerm_resource_group.degreed-identity-rg.location
  name                = "degreed-cluster-agentpool-identity"
  resource_group_name = azurerm_resource_group.degreed-identity-rg.name
  tags = {
    CostCenter  = "Data-Team"
    Environment = "Development"
    ManagedBy   = "Terraform"
    Owner       = "stewart_chris_l@yahoo.com"
    Project     = "degreed-web-sql-demo"
  }
}

#### Role Assignments

resource "azurerm_role_assignment" "github-actions-contributor" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.github-actions-identity.principal_id
}

resource "azurerm_role_assignment" "github-actions-acrpull" {
  scope                = azurerm_container_registry.degreed-acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.github-actions-identity.principal_id
}

resource "azurerm_role_assignment" "github-actions-acrpush" {
  scope                = azurerm_container_registry.degreed-acr.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.github-actions-identity.principal_id
}

resource "azurerm_role_assignment" "github-actions-AKS-Cluster-Admin" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = azurerm_user_assigned_identity.github-actions-identity.principal_id
}

resource "azurerm_role_assignment" "degreed-cluster-contributor" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.degreed-cluster-identity.principal_id
}

resource "azurerm_role_assignment" "degreed-cluster-agentpool-acrpull" {
  scope                = azurerm_container_registry.degreed-acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.degreed-cluster-agentpool-identity.principal_id
}

resource "azurerm_role_assignment" "degreed-network-contributor" {
  scope                = azurerm_virtual_network.degreed-vnet.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.degreed-cluster-identity.principal_id
}

#### SQL Server and Database
resource "azurerm_resource_group" "degreed-sql-server-rg" {
  name     = "degreed-sql-data-rg"
  location = "westus2"
}

resource "azurerm_mssql_server" "degreed-sql-server" {
  name                = "degreed-sql-server"
  resource_group_name = azurerm_resource_group.degreed-sql-server-rg.name
  location            = azurerm_resource_group.degreed-sql-server-rg.location
  version             = "12.0"
  tags = {
    CostCenter  = "Data-Team"
    Environment = "Development"
    ManagedBy   = "Terraform"
    Owner       = "stewart_chris_l@yahoo.com"
    Project     = "degreed-web-sql-demo"
  }
  azuread_administrator {
    azuread_authentication_only = true
    login_username              = "stewart_chris_l@yahoo.com"
    object_id                   = "95e5a25e-19af-4995-9ae6-eccede14b49b"
    tenant_id                   = "d20f231e-91f3-43e2-b15b-46963fe43452"
  }
}

resource "azurerm_mssql_database" "degreed-sql-database" {
  name                        = "degreed-data"
  server_id                   = azurerm_mssql_server.degreed-sql-server.id
  collation                   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb                 = 32
  sku_name                    = "GP_S_Gen5_1"
  min_capacity                = 0.5
  auto_pause_delay_in_minutes = -1
  tags = {
    CostCenter  = "Data-Team"
    Environment = "Development"
    ManagedBy   = "Terraform"
    Owner       = "stewart_chris_l@yahoo.com"
    Project     = "degreed-web-sql-demo"
  }
}
/* TODO: Add seed data to the database using a null_resource and local-exec provisioner. This will execute an Azure CLI command to run a SQL script against the database after it has been created.
# Seed Data using null_resource
resource "null_resource" "db_seed" {
  provisioner "local-exec" {
    command = "az sql db query --server ${azurerm_mssql_server.degreed-sql-server.name} --name ${azurerm_mssql_database.degreed-sql-database.name} --file seed.sql"
  }

  depends_on = [azurerm_mssql_database.degreed-sql-database]
}
*/

#### Network
resource "azurerm_resource_group" "degreed-network-rg" {
  name     = "degreed-network-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "degreed-vnet" {
  name                = "degreed-vnet"
  resource_group_name = azurerm_resource_group.degreed-network-rg.name
  location            = azurerm_resource_group.degreed-network-rg.location
  address_space       = ["10.240.0.0/12"]

  tags = {
    CostCenter  = "Network-Team"
    Environment = "Development"
    ManagedBy   = "Terraform"
    Owner       = "stewart_chris_l@yahoo.com"
    Project     = "degreed-web-sql-demo"
  }
}

resource "azurerm_subnet" "degreed-default-subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.degreed-network-rg.name
  virtual_network_name = azurerm_virtual_network.degreed-vnet.name
  address_prefixes     = ["10.240.0.0/16"]
}

resource "azurerm_subnet" "degreed-sql-subnet" {
  name                 = "sql-snet"
  resource_group_name  = azurerm_resource_group.degreed-network-rg.name
  virtual_network_name = azurerm_virtual_network.degreed-vnet.name
  address_prefixes     = ["10.241.0.0/24"]
}

resource "azurerm_private_dns_zone" "sql-privatelink-dns-zone" {
  name                = "sql.privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.degreed-network-rg.name
  tags = {
    CostCenter  = "Network-Team"
    Environment = "Development"
    ManagedBy   = "Terraform"
    Owner       = "stewart_chris_l@yahoo.com"
    Project     = "degreed-web-sql-demo"
  }
}

resource "azurerm_private_endpoint" "sql-pe" {
  custom_network_interface_name = "pe-sql-primary-eastus-nic"
  location                      = "eastus"
  name                          = "PE-SQL-PRIMARY-EASTUS"
  resource_group_name           = azurerm_resource_group.degreed-network-rg.name
  subnet_id                     = azurerm_subnet.degreed-sql-subnet.id
  tags = {
    CostCenter  = "Network-Team"
    Environment = "Development"
    ManagedBy   = "Terraform"
    Owner       = "stewart_chris_l@yahoo.com"
    Project     = "degreed-web-sql-demo"
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql-privatelink-dns-zone.id]
  }
  private_service_connection {
    is_manual_connection           = false
    name                           = "pe-sql-primary-eastus"
    private_connection_resource_id = azurerm_mssql_server.degreed-sql-server.id
    subresource_names              = ["sqlServer"]
  }
}


#### AKS Cluster
resource "azurerm_resource_group" "degreed-cluster-rg" {
  name     = "degreed-cluster-rg"
  location = "eastus"
}


resource "azurerm_kubernetes_cluster" "degreed-cluster" {
  name                      = "degreed-cluster"
  dns_prefix                = "degreedcluster"
  resource_group_name       = azurerm_resource_group.degreed-cluster-rg.name
  location                  = azurerm_resource_group.degreed-cluster-rg.location
  sku_tier                  = "Free"
  automatic_upgrade_channel = "stable"
  tags = {
    CostCenter  = "Data-Team"
    Environment = "Development"
    ManagedBy   = "Terraform"
    Owner       = "stewart_chris_l@yahoo.com"
    Project     = "degreed-web-sql-demo"
  }
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  api_server_access_profile {
    authorized_ip_ranges                = ["73.99.108.173/32"]
    virtual_network_integration_enabled = false
  }

  azure_active_directory_role_based_access_control {
    admin_group_object_ids = []
    azure_rbac_enabled     = true
    tenant_id              = data.azurerm_client_config.current.tenant_id
  }

  default_node_pool {
    auto_scaling_enabled         = true
    fips_enabled                 = false
    host_encryption_enabled      = false
    kubelet_disk_type            = "OS"
    max_count                    = 3
    max_pods                     = 110
    min_count                    = 2
    name                         = "agentpool"
    node_count                   = 2
    node_labels                  = {}
    node_public_ip_enabled       = false
    only_critical_addons_enabled = false
    orchestrator_version         = "1.34.4"
    os_disk_size_gb              = 128
    os_disk_type                 = "Managed"
    os_sku                       = "Ubuntu"
    scale_down_mode              = "Delete"
    tags = {
      CostCenter  = "Data-Team"
      Environment = "Development"
      ManagedBy   = "Terraform"
      Owner       = "stewart_chris_l@yahoo.com"
      Project     = "degreed-web-sql-demo"
    }
    type              = "VirtualMachineScaleSets"
    ultra_ssd_enabled = false
    vm_size           = "Standard_A2m_v2"
    vnet_subnet_id    = azurerm_subnet.degreed-default-subnet.id
    zones             = ["1", "2", "3"]
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
      undrainable_node_behavior     = "Cordon"
    }
  }
  identity {
    identity_ids = [azurerm_user_assigned_identity.degreed-cluster-identity.id]
    type         = "UserAssigned"
  }
  key_vault_secrets_provider {
    secret_rotation_enabled  = false
    secret_rotation_interval = "2m"
  }
  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.degreed-cluster-agentpool-identity.client_id
    object_id                 = azurerm_user_assigned_identity.degreed-cluster-agentpool-identity.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.degreed-cluster-agentpool-identity.id
  }
  maintenance_window_auto_upgrade {
    day_of_month = 0
    day_of_week  = "Sunday"
    duration     = 8
    frequency    = "Weekly"
    interval     = 1
    start_date   = "2026-04-21T00:00:00Z"
    start_time   = "00:00"
    utc_offset   = "+00:00"
    week_index   = "First"
  }
  maintenance_window_node_os {
    day_of_month = 0
    day_of_week  = "Sunday"
    duration     = 8
    frequency    = "Weekly"
    interval     = 1
    start_date   = "2026-04-21T00:00:00Z"
    start_time   = "00:00"
    utc_offset   = "+00:00"
    week_index   = "First"
  }

  node_provisioning_profile {
    default_node_pools = "Auto"
    mode               = "Manual"
  }
}

#### TODO: Create Namespaces
