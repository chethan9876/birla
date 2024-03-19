output "sqs_list" {
  description = "List of all sqs queues for alcyon backoffice application"
  value = [
    module.sqs_ca_image_transform_events.sqs_queue_arn,
    module.sqs_ca_image_transform_events.sqs_queue_dlq_arn,
    module.sqs_ca_print_notice_events.sqs_queue_arn,
    module.sqs_ca_print_notice_events.sqs_queue_dlq_arn,
    module.sqs_ca_print_letter_events.sqs_queue_arn,
    module.sqs_ca_print_letter_events.sqs_queue_dlq_arn,
    module.sqs_cask_image_transform_events.sqs_queue_arn,
    module.sqs_cask_image_transform_events.sqs_queue_dlq_arn,
    module.sqs_cask_print_notice_events.sqs_queue_arn,
    module.sqs_cask_print_notice_events.sqs_queue_dlq_arn,
    module.sqs_cask_print_letter_events.sqs_queue_arn,
    module.sqs_cask_print_letter_events.sqs_queue_dlq_arn,
    module.sqs_nsw_image_transform_events.sqs_queue_arn,
    module.sqs_nsw_image_transform_events.sqs_queue_dlq_arn,
    module.sqs_nsw_print_notice_events.sqs_queue_arn,
    module.sqs_nsw_print_notice_events.sqs_queue_dlq_arn,
    module.sqs_nsw_print_letter_events.sqs_queue_arn,
    module.sqs_nsw_print_letter_events.sqs_queue_dlq_arn,
    module.sqs_usa_image_transform_events.sqs_queue_arn,
    module.sqs_usa_image_transform_events.sqs_queue_dlq_arn,
    module.sqs_usa_print_notice_events.sqs_queue_arn,
    module.sqs_usa_print_notice_events.sqs_queue_dlq_arn,
    module.sqs_usa_print_letter_events.sqs_queue_arn,
    module.sqs_usa_print_letter_events.sqs_queue_dlq_arn,
    module.sqs_au_wa_image_transform_events.sqs_queue_arn,
    module.sqs_au_wa_image_transform_events.sqs_queue_dlq_arn,
    module.sqs_au_wa_print_notice_events.sqs_queue_arn,
    module.sqs_au_wa_print_notice_events.sqs_queue_dlq_arn,
    module.sqs_au_wa_print_letter_events.sqs_queue_arn,
    module.sqs_au_wa_print_letter_events.sqs_queue_dlq_arn
  ]
}

output "kms_key_list" {
  description = "List of all sqs queues for alcyon backoffice application"
  value = [
    module.sqs_kms_key.kms_key_arn
  ]
}