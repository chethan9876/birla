output "sqs_queue_arn" {
  description = "The ARN for the SQS queue created."
  value = aws_sqs_queue.sqs_queue.arn
}

output "sqs_queue_dlq_arn" {
  description = "The ARN for the SQS DLQ created."
  value = aws_sqs_queue.sqs_queue_dlq.arn
}

output "sqs_queue_name" {
  description = "The Name for the SQS queue created."
  value = aws_sqs_queue.sqs_queue.name
}