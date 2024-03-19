output "sqs_list" {
  description = "List of all sqs queues for alcyon backoffice application"
  value = [
    module.payment_due_notification_events.sqs_queue_arn,
    module.payment_due_notification_events.sqs_queue_dlq_arn,
    module.payment_received_events.sqs_queue_arn,
    module.payment_received_events.sqs_queue_dlq_arn,
    module.ingestr_incoming_oe_file_events.sqs_queue_arn,
    module.ingestr_incoming_oe_file_events.sqs_queue_dlq_arn

  ]
}

output "s3_list" {
  description = "List of all sqs queues for alcyon backoffice application"
  value = [
    module.original_evidence.s3_bucket_arn
  ]
}

output "kms_key_list" {
  description = "List of all sqs queues for alcyon backoffice application"
  value = [
    module.sqs_kms_key.kms_key_arn,
    module.s3_kms_key.kms_key_arn
  ]
}


