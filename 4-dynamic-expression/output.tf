output "security_rules" {
  value = azurerm_network_security_group.example.security_rule
}

output "env" {
  value = var.environment
}

output "demo" {
  value = [ for count in local.nsg_rules : count.value.description ]
}

output "splat_nsg_rules" {
  value = local.nsg_rules[*]
}

output "splat_nsg_rules_http" {
  value = local.nsg_rules[*].allow_http
}

output "splat_nsg_rules_http_description" {
  value = local.nsg_rules[*].allow_http.description
}