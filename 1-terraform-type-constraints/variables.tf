variable "environment" {
    type = string
    description = "the env type"
    default = "staging"
}

variable "storage_disk" {
    type = number
    description = "the size of the storage disk in GB"
    default = 80
}

variable "is_delete" {
    type = bool
    description = "whether to delete data disks on VM termination"
    default = true
}

variable "allowed_locations" {
    type = list(string)
    description = "List of allowed Azure locations"
    default = ["East US", "West Europe", "Southeast Asia"]
}

variable "resource_tags" {
    type = map(string)
    description = "Tags to be applied to resources"
    default = {
        environment = "Development"
        managed_by       = "DevOpsTeam"
        departement     = "devops"
    }
}

variable "network_config" {
    type = tuple([ string, string, number ])
    description = "Network configuration: [address_space, subnet_prefix, subnet_mask]"
    default = [ "10.0.0.0/16", "10.0.2.0", 24 ]
}

variable "admin_username" {
  type = set(string)
  description = "Admin username for the VM"
  default = ["adminuser"]
}

variable "vm_config" {
  type = object({
    size       = string
    publisher  = string
    offer      = string
    sku        = string
    version    = string
  })
  description = "Configuration for the virtual machine"
  default = {
    size      = "Standard_DS1_v2"
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}