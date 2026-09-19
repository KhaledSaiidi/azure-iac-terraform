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
      aws_s3_bucket.secure_bucket.arn,
      "${aws_s3_bucket.secure_bucket.arn}/*",
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
      aws_s3_bucket.secure_bucket.arn,
      "${aws_s3_bucket.secure_bucket.arn}/*",
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
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Alice"
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
      },
      {
        Sid    = "Allow use of the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Bob"
        },
        Action = [
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_s3_account_public_access_block" "account" {
  block_public_acls       = var.block_public_acls_account
  block_public_policy     = var.block_public_policy_account
  ignore_public_acls      = var.ignore_public_acls_account
  restrict_public_buckets = var.restrict_public_buckets_account
}



resource "aws_s3_bucket" "stamp_bucket" {
  bucket              = var.bucket_name
  object_lock_enabled = true
  tags                = var.tags
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.stamp_bucket.id

  block_public_acls       = var.block_public_acls_bucket
  block_public_policy     = var.block_public_policy_bucket
  ignore_public_acls      = var.ignore_public_acls_bucket
  restrict_public_buckets = var.restrict_public_buckets_bucket

}

resource "aws_s3_bucket_object_lock_configuration" "stamp_bucket_locking" {
  bucket = aws_s3_bucket.stamp_bucket.id

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 7
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "stamp_bucket_encryption" {
  bucket = aws_s3_bucket.stamp_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket_kms_key.arn
      sse_algorithm     = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_policy" "attach_enforce_tls" {
  count  = var.enforce_tls ? 1 : 0
  bucket = aws_s3_bucket.stamp_bucket.id
  policy = data.aws_iam_policy_document.enforce_tls.json
}