output "rds_cluster_endpoint" {
  description = "DB endpoint"
  value = aws_rds_cluster.db_cluster.endpoint
}

output "rds_security_group_id" {
  description = "The RDS Security group id created."
  value = aws_security_group.rds_security_group.id
}

output "rds_secret_name" {
  value =  data.aws_secretsmanager_secret.rds_secret.name
}

output "rds_secret_arn" {
  value = data.aws_secretsmanager_secret.rds_secret.arn
}
