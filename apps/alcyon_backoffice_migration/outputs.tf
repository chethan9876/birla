output "s3_list" {
  description = "List of all sqs queues for alcyon backoffice application"
  value = [
    module.preview_media_s3_bucket.s3_bucket_arn,
    module.legacy_media_s3_bucket.s3_bucket_arn
  ]
}

output "kms_key_list" {
  description = "List of all sqs queues for alcyon backoffice application"
  value = [
    module.s3_kms_key.kms_key_arn,
    module.docdb_kms_key.kms_key_arn,
    module.elasticache_kms_key.kms_key_arn
  ]
}