output "docdb_cluster_endpoint" {
  description = "DB endpoint"
  value = aws_docdb_cluster.cluster.endpoint
}

output "docdb_security_group_id" {
  description = "The RDS Security group id created."
  value = aws_security_group.docdb_security_group.id
}