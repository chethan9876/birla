output "s3_log_bucket_name" {
  description = "The bucket name for the S3 log bucket."
  value = aws_s3_bucket.s3_log_bucket.id
}

output "s3_kms_key_arn" {
  description = "KMS key for S3 buckets"
  value = module.s3_kms_key.kms_key_arn
}

output "sns_kms_key_arn" {
  description = "KMS Key for SNS"
  value = module.sns_kms_key.kms_key_arn
}

output "sqs_dlq_sns_topic_arn" {
  description = "The ARN for the sqs_dlq_alarm SNS topic."
  value = module.sqs_dlq_sns_topic.sns_topic_arn
}

output "crowd_strike_sg_id" {
  value = aws_security_group.crowdstrike_sg.id
}