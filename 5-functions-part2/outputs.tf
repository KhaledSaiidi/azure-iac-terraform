output "paths_to_validate" {
  value = var.paths_to_validate
}

output "validation_results" {
  value = local.validations
}

output "directories" {
  value = local.directories
}

output "missing_paths" {
  value = local.missing_paths
}

output "status_summary" {
  value = local.status_summary
}

output "file_content" {
  # jsondecode(string) -> any
  # - Parses a JSON string into a Terraform value (map/list/etc).
  # Structure: jsondecode(<string>)
  #
  # nonsensitive(value) -> any
  # - Removes the sensitive marking from a value.
  # Structure: nonsensitive(<value>)
  #
  # Here, we decode the JSON config file and expose it as a regular output.
  value = nonsensitive(jsondecode(local.config_file_content))
}
