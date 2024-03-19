output "alcyon_records_manager_rds_cluster_endpoint" {
  description = "Alcyon records manager RDS DB cluster endpoint"
  value = module.rds_db.rds_cluster_endpoint
}

output "alcyon_records_manager_rds_security_group_id" {
  description = "Alcyon records manager RDS Security group id."
  value = module.rds_db.rds_security_group_id
}

output "sqs_list" {
  description = "List of all sqs queues for alcyon backoffice application"
  value = [
    module.sqs_archive_events.sqs_queue_arn,
    module.sqs_archive_events.sqs_queue_dlq_arn,
    module.sqs_purge_events.sqs_queue_arn,
    module.sqs_purge_events.sqs_queue_dlq_arn,
    module.sqs_purge_trigger_events.sqs_queue_arn,
    module.sqs_purge_trigger_events.sqs_queue_dlq_arn,
    module.sqs_registrr_purge_events.sqs_queue_arn,
    module.sqs_registrr_purge_events.sqs_queue_dlq_arn,
    module.sqs_registrr_purge_trigger_events.sqs_queue_arn,
    module.sqs_registrr_purge_trigger_events.sqs_queue_dlq_arn,
    module.sqs_dataextractr_archive_ready_events.sqs_queue_arn,
    module.sqs_dataextractr_archive_ready_events.sqs_queue_dlq_arn
  ]
}

output "s3_list" {
  description = "List of all sqs queues for alcyon backoffice application"
  value = [
    module.archive_s3_bucket.s3_bucket_arn,
    module.purge_s3_bucket.s3_bucket_arn,
    module.registrr_archive_s3_bucket.s3_bucket_arn
  ]
}

output "kms_key_list" {
  description = "List of all sqs queues for alcyon backoffice application"
  value = [
    module.s3_kms_key.kms_key_arn,
    module.sqs_kms_key.kms_key_arn
  ]
}