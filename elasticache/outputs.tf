output "elasticache_cluster_endpoint" {
  description = "DB endpoint"
  value = aws_elasticache_replication_group.elasticache_cluster_replication_group.primary_endpoint_address
}

output "elasticache_security_group_id" {
  description = "The RDS Security group id created."
  value = aws_security_group.elasticache_security_group.id
}