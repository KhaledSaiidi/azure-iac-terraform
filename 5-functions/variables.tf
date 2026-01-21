variable "project_name" {
  type = string
  default = "Project Alpha Resource"
}

variable "default_tags" {
  type = map(string)
  default = {
    environment = "development"
    owner       = "team-alpha"
  }
}

variable "environment_tags" {
  type = map(string)
  default = {
    environment = "production"
    cost_center       = "cc-123"
  }
}

variable "storage_account_name" {
  type = string
  default = "!storage account &  ?"
}

variable "allowed_ports" {
  type = string
  default = "80,443,3306"
}
