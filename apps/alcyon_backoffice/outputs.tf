output "sqs_list" {
  description = "List of all sqs queues for alcyon backoffice application"
  value = [
    module.sqs_adjudication_export_events.sqs_queue_arn,
    module.sqs_collection_events.sqs_queue_arn,
    module.sqs_collection_paymentupdate_events.sqs_queue_arn,
    module.sqs_court_export_events.sqs_queue_arn,
    module.sqs_deployment_events.sqs_queue_arn,
    module.sqs_image_transform_events.sqs_queue_arn,
    module.sqs_ingestr_incoming_file_events.sqs_queue_arn,
    module.sqs_print_letter_events.sqs_queue_arn,
    module.sqs_print_notice_events.sqs_queue_arn,
    module.sqs_adjudication_export_events.sqs_queue_dlq_arn,
    module.sqs_collection_events.sqs_queue_dlq_arn,
    module.sqs_collection_paymentupdate_events.sqs_queue_dlq_arn,
    module.sqs_court_export_events.sqs_queue_dlq_arn,
    module.sqs_deployment_events.sqs_queue_dlq_arn,
    module.sqs_image_transform_events.sqs_queue_dlq_arn,
    module.sqs_ingestr_incoming_file_events.sqs_queue_dlq_arn,
    module.sqs_print_letter_events.sqs_queue_dlq_arn,
    module.sqs_print_notice_events.sqs_queue_dlq_arn
  ]
}

output "s3_list" {
  description = "List of all sqs queues for alcyon backoffice application"
  value = [
    module.media_s3_bucket.s3_bucket_arn,
    module.template_s3_bucket.s3_bucket_arn
  ]
}

output "kms_key_list" {
  description = "List of all sqs queues for alcyon backoffice application"
  value = [
    module.s3_kms_key.kms_key_arn,
    module.sqs_kms_key.kms_key_arn
  ]
}

