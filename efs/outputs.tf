output "efs_security_group_id" {
  description = "The EFS security group id."
  value = aws_security_group.efs_security_group.id
}

output "efs_dns_name" {
  description = "The EFS CNAME."
  value = aws_route53_record.efs_route53_record.name
}

output "efs_arn" {
  description = "Arn of the EFS share"
  value = aws_efs_file_system.efs.arn
}

output "efs_id" {
  description = "ID of the efs fileshare"
  value = aws_efs_file_system.efs.id
}