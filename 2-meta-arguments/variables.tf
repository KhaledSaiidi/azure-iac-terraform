variable "environment" {
  type        = string
  description = "the env type"
  default     = "staging"
}

variable "allowed_locations" {
  type        = list(string)
  description = "List of allowed Azure locations"
  default     = ["East US", "West Europe", "Southeast Asia"]
}

variable "resource_tags" {
  type        = map(string)
  description = "Tags to be applied to resources"
  default = {
    environment = "Development"
    managed_by  = "DevOpsTeam"
    departement = "devops"
  }
}

variable "storage_account_name" {
  type    = list(string)
  default = ["mystorageaccount", "mystorageaccount2", "mystorageaccount3"]
}

variable "enable_storage_account" {
  type    = bool
  default = true
}

variable "container_names" {
  type    = list(string)
  default = ["logs", "reports", "backups"]
}

variable "resource_groups" {
  type = map(string)
  default = {
    core = "westeurope"
    ops  = "northeurope"
    dev  = "francecentral"
  }
}

variable "storage_accounts" {
  type = map(object({
    replication_type = string
    tags             = map(string)
  }))

  default = {
    sa1 = {
      replication_type = "LRS"
      tags             = { environment = "dev", owner = "team-a" }
    }
    sa2 = {
      replication_type = "GRS"
      tags             = { environment = "staging", owner = "team-b" }
    }
  }
}