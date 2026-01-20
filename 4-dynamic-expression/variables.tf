# variables.tf
variable "environment" {
  description = "Environment name used in tags."
  type        = string
  default     = "uat"
}