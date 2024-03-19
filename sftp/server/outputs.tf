output "sftp_cluster_endpoint" {
  description = "sftp endpoint"
  value       = aws_transfer_server.sftp_server.endpoint
}

output "sftp_security_group_id" {
  description = "The sftp Security group id created."
  value       = aws_security_group.sftp_security_group.id
}

output "sftp_server_id" {
  description = "The sftp Security group id created."
  value       = aws_transfer_server.sftp_server.id
}


