output "lambda_arn" {
  description = "The ARN for the lambda created."
  value = aws_lambda_function.lambda_function.arn
}

output "lambda_sg_id" {
  description = "The ARN for lambda's security group"
  value = aws_security_group.lambda_security_group.id
}
