locals {
  common_tags = {
    environment = var.environment
    lob = "banking"
    stage = "alpha"
  }
}