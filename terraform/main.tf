terraform {
  required_version = ">= 0.13.2"
}

provider "azurerm" {
  features {}
}

// Resource group is assumed to exist
data "azurerm_resource_group" "aks" {
  name     = var.aks_rg_name
}

// AAD Group is assumed to exist
data "azuread_group" "aks_admin_group" {
  display_name = var.aks_admin_group
}

data "azurerm_subnet" "subnet" {
  name = var.node_subnet
  virtual_network_name = var.node_vnet
  resource_group_name = var.node_vnet_rg
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  kubernetes_version  = "1.19.6"
  location            = data.azurerm_resource_group.aks.location
  resource_group_name = data.azurerm_resource_group.aks.name
  dns_prefix          = var.aks_cluster_name
  
  private_cluster_enabled = false


  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = file("${var.ssh_public_key}")
    }
  }

  default_node_pool {
    name               = "default"
    type               = "VirtualMachineScaleSets"
    availability_zones = [1, 2, 3]
    node_count         = 3
    vnet_subnet_id = data.azurerm_subnet.subnet.id
    enable_auto_scaling   = true
    enable_node_public_ip = false
    max_count             = 5
    min_count             = 3
    os_disk_size_gb       = 50
    max_pods              = 220
    vm_size               = "Standard_D2_v2"
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed = true
      admin_group_object_ids = [data.azuread_group.aks_admin_group.object_id]
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    network_policy    = "calico"
    load_balancer_sku = "Standard"
    pod_cidr = "10.22.0.0/20"
  }

  addon_profile {
    kube_dashboard {
      enabled = false
    }
    azure_policy {
      enabled = true
    }
  }

  lifecycle {
    ignore_changes = [ default_node_pool[0].node_count ]
  }

}

data "azurerm_storage_account" "logstorage" {
  name = var.log_storage_acct
  resource_group_name = var.log_storage_rg
}

resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "aks-diagnostic"
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  storage_account_id = data.azurerm_storage_account.logstorage.id

  log {
    category = "kube-apiserver"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }

  log {
    category = "kube-controller-manager"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }

  log {
    category = "kube-scheduler"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }

  log {
    category = "kube-audit"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }

  log {
    category = "kube-audit-admin"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }


  log {
    category = "guard"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }

  log {
    category = "cluster-autoscaler"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }
}
