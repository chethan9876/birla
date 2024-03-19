locals {
  application = "alcyon-express"
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
  db_name                           = "alcyon_express_db"
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

module "msk_kms_key" {
  source = "../../templates/kms"
  application = local.application
  client = local.client
  environment = var.environment
  name = "msk"
}

module "msk" {
  source = "../../templates/msk"
  application = local.application
  client = local.client
  msk_version = var.msk_version
  msk_instance_type = var.msk_instance_type
  msk_kms_key_arn = module.msk_kms_key.kms_key_arn
  msk_ebs_size = var.msk_ebs_size
  subnet_ids = var.db_subnet_ids
  environment = var.environment
  name = "msk"
  vpc_id = var.vpc_id
  sns_topic = var.sns_topic
}

module "elasticsearch_kms_key" {
  source      = "../../templates/kms"
  environment = var.environment
  client      = local.client
  application = local.application
  name        = "elasticsearch"
}
module "elasticsearch" {
  source = "../../templates/elasticsearch"

  environment                         = local.environment
  region                              = var.region
  client                              = local.client
  iam_arn_prefix                      = var.iam_arn_prefix
  application                         = local.application
  eks_cluster_admin_security_group_id = var.admin_security_group_id
  eks_cluster_security_group_id       = var.eks_cluster_security_group_id
  es_kms_key_arn                      = module.elasticsearch_kms_key.kms_key_arn
  s3_kms_key_arn                      = var.es_s3_kms_key_arn
  s3_log_bucket                       = var.s3_log_bucket
  es_instance_count                   = 2
  subnet_ids                          = slice(tolist(var.internal_subnet_ids), 0, 2)
  vpc_id                              = var.vpc_id
  hosted_zone_id                      = var.hosted_zone_id
  hosted_zone_name                    = var.hosted_zone_name
  es_snapshot_s3_bucket               = var.es_snapshot_s3
  sns_topic                           = var.sns_topic
  es_retention_days                   = var.es_retention_days
  jumpbox_security_group_id           = var.jumpbox_security_group_id
}