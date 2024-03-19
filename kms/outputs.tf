output "kms_key_arn" {
  description = "The ARN for the KMS key created."
  value = aws_kms_key.kms_key.arn
}