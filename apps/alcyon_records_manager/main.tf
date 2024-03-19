locals {
  application = "alcyon-records-manager"
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
  db_name                           = "alcyon_records_manager_db"
  db_cluster_parameter_group_family = var.db_cluster_parameter_group_family
  db_kms_key_arn                    = module.rds_kms_key.kms_key_arn
  db_snapshot_identifier            = var.db_snapshot_identifier
  db_subnet_group_name              = var.db_subnet_group_name
  db_engine_version                 = var.db_engine_version
  db_instance_count                 = var.db_instance_count
  db_performance_insights_enabled   = var.db_performance_insights_enabled
  hosted_zone_id                    = var.hosted_zone_id
  hosted_zone_name                  = var.hosted_zone_name
  instance_class                    = var.db_instance_class
}

module "s3_kms_key" {
  source      = "../../templates/kms"
  application = local.application
  client      = local.client
  environment = var.environment
  name        = "s3"
}

module "archive_s3_bucket" {
  source             = "../../templates/s3"
  application        = local.application
  client             = local.client
  environment        = var.environment
  aws_kms_s3_key_arn = module.s3_kms_key.kms_key_arn
  name               = "archive"
  s3_log_bucket      = var.s3_log_bucket
  s3_lifecycle_rules = [
    {
      enabled                            = true
      prefix                             = ""
      current_version_transitions        = [
        {
          storage_class = "STANDARD_IA"
          days          = 30
        }
      ],
      current_version_expiration_days    = null
      noncurrent_version_transitions     = [],
      noncurrent_version_expiration_days = 5
    }
  ]
}

module "purge_s3_bucket" {
  source             = "../../templates/s3"
  application        = local.application
  client             = local.client
  environment        = var.environment
  aws_kms_s3_key_arn = module.s3_kms_key.kms_key_arn
  name               = "purge"
  s3_log_bucket      = var.s3_log_bucket
  s3_lifecycle_rules = [
    {
      enabled                            = true
      prefix                             = ""
      current_version_transitions        = [
        {
          storage_class = "STANDARD_IA"
          days          = 30
        }
      ],
      current_version_expiration_days    = null
      noncurrent_version_transitions     = [],
      noncurrent_version_expiration_days = 5
    }
  ]
}

module "registrr_archive_s3_bucket" {
  source             = "../../templates/s3"
  application        = local.application
  client             = local.client
  environment        = var.environment
  aws_kms_s3_key_arn = module.s3_kms_key.kms_key_arn
  name               = "registrr-archive"
  s3_log_bucket      = var.s3_log_bucket
  s3_lifecycle_rules = [
    {
      enabled                            = true
      prefix                             = ""
      current_version_transitions        = [
        {
          storage_class = "STANDARD_IA"
          days          = 30
        }
      ],
      current_version_expiration_days    = null
      noncurrent_version_transitions     = [],
      noncurrent_version_expiration_days = 5
    }
  ]
}


module "sqs_kms_key" {
  source      = "../../templates/kms"
  application = local.application
  client      = local.client
  environment = var.environment
  name        = "sqs"
}

module "sqs_archive_events" {
  source              = "../../templates/sqs"
  name                = "archive-events"
  application         = local.application
  sqs_kms_key_arn     = module.sqs_kms_key.kms_key_arn
  client              = local.client
  environment         = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_purge_events" {
  source              = "../../templates/sqs"
  name                = "purge-events"
  application         = local.application
  sqs_kms_key_arn     = module.sqs_kms_key.kms_key_arn
  client              = local.client
  environment         = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_purge_trigger_events" {
  source              = "../../templates/sqs"
  name                = "purge-trigger-events"
  application         = local.application
  sqs_kms_key_arn     = module.sqs_kms_key.kms_key_arn
  client              = local.client
  environment         = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
  max_receive_count   = 144
}

module "sqs_registrr_purge_events" {
  source              = "../../templates/sqs"
  name                = "registrr-purge-events"
  application         = local.application
  sqs_kms_key_arn     = module.sqs_kms_key.kms_key_arn
  client              = local.client
  environment         = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_registrr_purge_trigger_events" {
  source              = "../../templates/sqs"
  name                = "registrr-purge-trigger-events"
  application         = local.application
  sqs_kms_key_arn     = module.sqs_kms_key.kms_key_arn
  client              = local.client
  environment         = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
  delay_seconds       = 300
  max_receive_count   = 3
}

module "sqs_dataextractr_archive_ready_events" {
  source              = "../../templates/sqs"
  name                = "dataextractr-archive-ready-events"
  application         = local.application
  sqs_kms_key_arn     = module.sqs_kms_key.kms_key_arn
  client              = local.client
  environment         = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}