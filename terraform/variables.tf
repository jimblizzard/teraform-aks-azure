variable "aks_rg_name" {
  type    = string
  default = "Your Resource Group Name"
}

variable "aks_rg_location" {
  type    = string
  default = "East US"
}

variable "aks_cluster_name" {
  type    = string
  default = "Your Cluster Name"
}

variable "aks_admin_group" {
  type    = string
  default = "Azure AD Group for your administrators"
}

// Update with a path to your SSH key.
variable "ssh_public_key" {
  type    = string
  default = "../.ssh/id_rsa.pub"
}

variable "node_vnet" {
  type = string
  default = "Name of your Virtual Network"
}

variable "node_subnet" {
  type = string
  default = "Name of your Subnet"
}

variable "node_vnet_rg" {
  type = string
  default = "Resource Group where your VNET is located"
}

variable "log_storage_acct" {
  type = string
  default = "A storage account to host Kubernetes log files"
}

variable "log_storage_rg" {
  type = string
  default = "Resource group for your storage account"
}