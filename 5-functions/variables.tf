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

variable "environment" {
  type = string
  description = "The deployment environment"  
  default = "dev"
  validation {
    condition = contains(["dev", "stg", "prod"], var.environment)
    error_message = "Enter valid value"
  }
}

variable "vm_sizes" {
  type = map(string)
  default = {
    "dev" = "Standard_D2s_v3",
    "stg" = "Standard_D4s_v3",
    "prod" = "Standard_D8s_v3"
  }
  validation {
    condition = [ 
      alltrue([
        for size in values(var.vm_sizes) : length(size) < 20 && strcontains(lower(size), lower("Standard_")) 
      ])
    ]
    error_message = "Enter valid size"
  }
}

#Day 2: 16:16 https://www.youtube.com/watch?v=wzdmKnzSoNI&list=PLl4APkPHzsUUHlbhuq9V02n9AMLPySoEQ&index=13