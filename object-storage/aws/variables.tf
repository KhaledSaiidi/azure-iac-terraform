variable "bucket_description" {
  type    = string
  default = "KMS key for S3 bucket encryption"
}

variable "enable_key_rotation" {
  type    = bool
  default = true
}

variable "deletion_window_in_days" {
  type    = number
  default = 30
}

variable "bucket_name" {
  type    = string
  default = "my-stamp-bucket-"
}


variable "tags" {
  type = map(string)
  default = {
    "Name"        = "My stamp_bucket"
    "Environment" = "stamp"
  }
}


variable "object_lock_enabled" {
  type    = bool
  default = true
}

variable "stamp_bucket_locking_default_retention_mode" {
  type    = string
  default = "COMPLIANCE"
}

variable "stamp_bucket_locking_default_retention_days" {
  type    = number
  default = 7
}

variable "block_public_acls_bucket" {
  type    = bool
  default = true
}
variable "block_public_policy_bucket" {
  type    = bool
  default = true
}
variable "ignore_public_acls_bucket" {
  type    = bool
  default = true
}
variable "restrict_public_buckets_bucket" {
  type    = bool
  default = true
}

variable "enforce_tls" {
  type    = bool
  default = true
}
variable "key_admin_principal" {
  type    = string
  default = "456441406929:user/khaleds"
}

variable "versioning_configuration_status" {
  type    = string
  default = "Enabled"
}