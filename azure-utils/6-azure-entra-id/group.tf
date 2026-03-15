resource "azuread_group" "administrators" {
  display_name = "Administrators Department"
  security_enabled = true
}

resource "azuread_group_member" "administrators" {
  for_each = { for u in azuread_user.users: u.mail_nickname => u if u.department == "Administrators" }

  group_object_id  = azuread_group.administrators.id
  member_object_id = each.value.id
}

resource "azuread_group" "engineers" {
  display_name = "IT - Engineers"
  security_enabled = true
}

resource "azuread_group_member" "engineers" {
  for_each = { for u in azuread_user.users: u.mail_nickname => u if u.department == "Engineering" }

  group_object_id  = azuread_group.engineers.id
  member_object_id = each.value.id
}

resource "azuread_directory_role_assignment" "administrators_global_admin" {
  role_id             = azuread_directory_role.global_admin.template_id
  principal_object_id = azuread_group.administrators.id
}

resource "azuread_directory_role" "global_admin" {
  display_name = "Global Administrator"
}

resource "azuread_application" "engineers_app" {
  display_name = "Engineers App"

  app_role {
    allowed_member_types = ["User", "Group"]
    description          = "Engineer access to the app"
    display_name         = "Engineer Access"
    enabled              = true
    id                   = uuid()
    value                = "Engineer.Access"
  }
}

resource "azuread_service_principal" "engineers_app" {
  client_id = azuread_application.engineers_app.client_id
}

resource "azuread_app_role_assignment" "engineers_app_role" {
  principal_object_id = azuread_group.engineers.id
  resource_object_id  = azuread_service_principal.engineers_app.id
  app_role_id         = azuread_application.engineers_app.app_role_ids["Engineer.Access"]
}
