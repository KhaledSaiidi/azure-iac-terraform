locals {
  domain_name = data.azuread_domains.primary.domains.0.domain_name
  users = csvdecode(file("users.csv"))
}

data "azuread_domains" "primary" {
    only_initial = true
}


resource "azuread_user" "users" {
    for_each = { for user in local.users: user.first_name => user }
    user_principal_name = format("%s%s@%s", 
    substr(each.value.first_name, 0, 1), 
    lower(each.value.last_name), 
    local.domain_name
    )

    display_name        = "${each.value.first_name} ${each.value.last_name}"
    mail_nickname       = "${each.value.first_name}.${each.value.last_name}"
    password            = var.users_password
    force_password_change = true
    department = each.value.department
    job_title = each.value.job_title
}