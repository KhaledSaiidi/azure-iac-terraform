data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "enforce_tls" {
  statement {
    sid    = "EnforceTLSv12OrHigher"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.stamp_bucket.arn,
      "${aws_s3_bucket.stamp_bucket.arn}/*",
    ]

    # Condition 1: Deny any non-HTTPS traffic
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "DenyOlderTLSVersions"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.stamp_bucket.arn,
      "${aws_s3_bucket.stamp_bucket.arn}/*",
    ]

    # Condition 2: Deny protocols older than TLS 1.2
    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = ["1.2"]
    }
  }
}

resource "aws_kms_key" "bucket_kms_key" {
  description             = var.bucket_description
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow administration of the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.key_admin_principal}"
        },
        Action = [
          "kms:ReplicateKey",
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_s3_bucket" "stamp_bucket" {
  bucket_prefix       = var.bucket_name
  object_lock_enabled = var.object_lock_enabled
  tags                = var.tags
}

resource "aws_s3_bucket_versioning" "versioning_enabled" {
  bucket = aws_s3_bucket.stamp_bucket.id
  versioning_configuration {
    status = var.versioning_configuration_status
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.stamp_bucket.id

  block_public_acls       = var.block_public_acls_bucket
  block_public_policy     = var.block_public_policy_bucket
  ignore_public_acls      = var.ignore_public_acls_bucket
  restrict_public_buckets = var.restrict_public_buckets_bucket

}

resource "aws_s3_bucket_object_lock_configuration" "stamp_bucket_locking" {
  count  = var.object_lock_enabled ? 1 : 0
  bucket = aws_s3_bucket.stamp_bucket.id

  rule {
    default_retention {
      mode = var.stamp_bucket_locking_default_retention_mode
      days = var.stamp_bucket_locking_default_retention_days
    }
  }
  depends_on = [aws_s3_bucket_versioning.versioning_enabled]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "stamp_bucket_encryption" {
  bucket = aws_s3_bucket.stamp_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "attach_enforce_tls" {
  count  = var.enforce_tls ? 1 : 0
  bucket = aws_s3_bucket.stamp_bucket.id
  policy = data.aws_iam_policy_document.enforce_tls.json
}