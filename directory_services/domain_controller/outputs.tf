output "domaincontroller_security_group_id" {
  description = "The Domain Controller security group id."
  value       = aws_security_group.domaincontroller_security_group.id
}



output "domaincontroller_private_ip" {
  description = "The Domain Controller security group id."
  value       = aws_instance.domaincontroller_ec2.private_ip
}