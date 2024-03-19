output "sns_topic_arn" {
  description = "The ARN for the SNS topic created."
  value = aws_sns_topic.sns_topic.arn
}