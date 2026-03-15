output "azuread_default_domain" {
  value = local.domain_name
}

output "usernamers" {
  value = [for user in local.users : "${user.first_name}.${user.last_name}"]
}
