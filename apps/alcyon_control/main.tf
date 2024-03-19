locals {
  application = "alcyon-control"
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
  db_name                           = "alcyon_control_db"
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

//TODO: TI-13: try tunnelling to run rds script
#data template_file "create_db_schema" {
#  template = file("${path.module}/resources/run_rds_query.sh")
#  vars = {
#    db_url = module.rds_db.rds_cluster_endpoint
#    db_password = var.db_master_password
#    queries = templatefile("${path.module}/resources/create_db_schema.sql", {
#      db_password = var.db_master_password
#    })
#  }
#}
#
#module "rds_ssm" {
#  source = "../../templates/ssm"
#  environment = var.environment
#  client = local.client
#  application = local.application
#  name = "rds"
#  ssm_content_command = data.template_file.create_db_schema.rendered
#  ssm_content_description = "Run queries to create DB and schema"
#  ssm_association_tag = var.eks_cluster_admin_tag_name
#}

module "s3_kms_key" {
  source      = "../../templates/kms"
  application = local.application
  client      = local.client
  environment = var.environment
  name        = "s3"
}

module "timeseries_data_s3_bucket" {
  source             = "../../templates/s3"
  application        = local.application
  client             = local.client
  environment        = var.environment
  aws_kms_s3_key_arn = module.s3_kms_key.kms_key_arn
  name               = "timeseries-data"
  s3_log_bucket      = var.s3_log_bucket
}

module "ccu_data_s3_bucket" {
  source             = "../../templates/s3"
  application        = local.application
  client             = local.client
  environment        = var.environment
  aws_kms_s3_key_arn = module.s3_kms_key.kms_key_arn
  name               = "ccu-data"
  s3_log_bucket      = var.s3_log_bucket
}

module "reviewr_s3_bucket" {
  source             = "../../templates/s3"
  application        = local.application
  client             = local.client
  environment        = var.environment
  aws_kms_s3_key_arn = module.s3_kms_key.kms_key_arn
  name               = "reviewr"
  s3_log_bucket      = var.s3_log_bucket
}
