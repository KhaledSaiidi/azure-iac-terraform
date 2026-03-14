locals {
  nsg_rules = {
    "allow_http" = {
      priority               = 100
      destination_port_range = "80"
      description            = "Allow HTTP traffic"
    },
    "allow_https" = {
      priority               = 200
      destination_port_range = "443"
      description            = "Allow HTTPS traffic"
    }
  }
}