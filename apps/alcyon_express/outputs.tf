output "alcyon_express_rds_cluster_endpoint" {
  description = "Alcyon Express RDS DB cluster endpoint"
  value = module.rds_db.rds_cluster_endpoint
}

output "alcyon_express_rds_security_group_id" {
  description = "Alcyon Express RDS Security group id."
  value = module.rds_db.rds_security_group_id
}

output "msk_security_group" {
  value = module.msk.msk_security_group_id
}

output "elasticsearch_endpoint" {
  value = module.elasticsearch.es_endpoint
}