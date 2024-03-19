

output "itservice_security_group_id" {
  description = "The IT Services security group id."
  value       = aws_security_group.itservice_security_group.id
}

