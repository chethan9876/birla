output "alcyon_control_rds_cluster_endpoint" {
  description = "Alcyon Control RDS DB cluster endpoint"
  value = module.rds_db.rds_cluster_endpoint
}

output "alcyon_control_rds_security_group_id" {
  description = "Alcyon Control RDS Security group id."
  value = module.rds_db.rds_security_group_id
}

output "s3_list" {
  description = "List of all sqs queues for alcyon backoffice application"
  value = [
    module.timeseries_data_s3_bucket.s3_bucket_arn,
    module.ccu_data_s3_bucket.s3_bucket_arn,
    module.reviewr_s3_bucket.s3_bucket_arn
  ]
}

output "kms_key_list" {
  description = "List of all sqs queues for alcyon backoffice application"
  value = [
    module.s3_kms_key.kms_key_arn
  ]
}