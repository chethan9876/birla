locals {
  application = "alcyon-migration"
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  prefix = "${local.environment}-${local.client}-${local.application}"
}

module "elasticache" {
  source = "../../templates/elasticache"
  application = local.application
  client = local.client
  environment = var.environment
  vpc_id = var.vpc_id
  database_subnet_ids = var.database_subnet_ids
  hosted_zone_name = var.hosted_zone_name
  hosted_zone_id = var.hosted_zone_id
  elasticache_engine_version = var.elasticache_engine_version
  elasticache_snapshot_identifier = var.elasticache_snapshot_identifier
  elasticache_replica_count = var.elasticache_replica_count
  elasticache_param_group_family = var.elasticache_param_group_family
  elasticache_node_type = var.elasticache_node_type
  sns_topic = var.sns_topic
}

module "docdb" {
  source = "../../templates/docdb"
  application = local.application
  client = local.client
  environment = var.environment
  vpc_id = var.vpc_id
  database_subnet_ids = var.database_subnet_ids
  docdb_engine_version = var.docdb_engine_version
  docdb_param_group_family = var.docdb_param_group_family
  docdb_param_group_tls_enabled = var.docdb_param_group_tls_enabled
  docdb_instance_count = var.docdb_instance_count
  docdb_snapshot_identifier = var.docdb_snapshot_identifier
  docdb_instance_class = var.docdb_instance_class
  docdb_kms_key_arn = module.docdb_kms_key.kms_key_arn
  hosted_zone_name = var.hosted_zone_name
  hosted_zone_id = var.hosted_zone_id
  sns_topic = var.sns_topic

}
