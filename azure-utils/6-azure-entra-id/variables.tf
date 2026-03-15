variable "users_password" {
  description = "The password to be assigned to the created users."
  type        = string
  sensitive = true
  default       = "P@ssw0rd1234!"
}