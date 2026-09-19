output "bucket_name" {
  value = aws_s3_bucket.stamp_bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.stamp_bucket.arn
}

output "kms_key_arn" {
  value = aws_kms_key.bucket_kms_key.arn
}

output "kms_key_id" {
  value = aws_kms_key.bucket_kms_key.key_id
}