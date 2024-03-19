locals {
  application = "alcyon-field-service"
  client      = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  prefix      = "${local.environment}-${local.client}-${local.application}"
}

module "rds_kms_key" {
  source      = "../../templates/kms"
  application = local.application
  client      = local.client
  environment = var.environment
  name        = "rds"
}

module "rds_db" {
  source                            = "../../templates/rds"
  environment                       = var.environment
  application                       = local.application
  client                            = local.client
  vpc_id                            = var.vpc_id
  db_name                           = "alcyon_field_service_db"
  db_performance_insights_enabled   = var.db_performance_insights_enabled
  db_cluster_parameter_group_family = var.db_cluster_parameter_group_family
  db_kms_key_arn                    = module.rds_kms_key.kms_key_arn
  db_snapshot_identifier            = var.db_snapshot_identifier
  db_subnet_group_name              = var.db_subnet_group_name
  db_engine_version                 = var.db_engine_version
  db_instance_count                 = var.db_instance_count
  instance_class                    = var.db_instance_class
  hosted_zone_id                    = var.hosted_zone_id
  hosted_zone_name                  = var.hosted_zone_name
}

