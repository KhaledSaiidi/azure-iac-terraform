variable "project_name" {
  type    = string
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
    cost_center = "cc-123"
  }
}

variable "storage_account_name" {
  type    = string
  default = "!storage account &  ?"
}

variable "allowed_ports" {
  type    = string
  default = "80,443,3306"
}

variable "environment" {
  type        = string
  description = "The deployment environment"
  default     = "dev"

  validation {
    # contains(list, value) -> bool
    # - Returns true if `value` exists inside the given list.
    # Here, we restrict the environment to a predefined set of allowed values.
    condition = contains(["dev", "stg", "prod"], var.environment)

    error_message = "Enter valid value"
  }
}

variable "vm_sizes" {
  type = map(string)
  default = {
    "dev"  = "Standard_D2s_v3",
    "stg"  = "Standard_D4s_v3",
    "prod" = "Standard_D8s_v3"
  }

  validation {
    # values(map) -> list(any)
    # - Extracts all values from a map into a list.
    # lower(string) -> string
    # - Converts a string to lowercase.
    # strcontains(string, substring) -> bool
    # - Returns true if `substring` exists within `string`.
    # length(string) -> number
    # - Returns the number of characters in a string.
    # for-expressions: [for <value> in <collection> : <expr>]
    # - Iterates over a collection and produces a new list.
    # alltrue(list(bool)) -> bool
    # - Returns true only if *all* elements in the list are true.
    #
    # Here, we validate that:
    # - each VM size name is shorter than 20 characters
    # - and each size starts with "Standard_" (case-insensitive).
    condition = alltrue([
      for size in values(var.vm_sizes) :
      length(size) < 20 && strcontains(lower(size), lower("Standard_"))
    ])

    error_message = "Enter valid size"
  }
}

variable "backup_name" {
  type    = string
  default = "test_backup"

  validation {
    # endswith(string, suffix) -> bool
    # - Returns true if `string` ends with the specified `suffix`.
    # Here, we enforce a naming convention for backups.
    condition = endswith(var.backup_name, "_backup")

    error_message = "Should ends with _backup"
  }
}

variable "credential" {
  type      = string
  default   = "xyz12345"
  sensitive = true
}
