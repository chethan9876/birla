output "ssm_document_arn" {
  description = "The ARN for the SSM document created."
  value = aws_ssm_document.ssm_document.arn
}