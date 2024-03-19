data "aws_caller_identity" "current" {}
locals {
  client = "au-nt"
  region = "ap-southeast-2"
  iam_arn_prefix = "arn:aws"
  account_id = data.aws_caller_identity.current.account_id
}

provider "aws" {
  profile = local.client
  region  = local.region
}

terraform {
  backend "s3" {}
}

module "core_network" {
  source                             = "../../core/core_network"
  profile                            = local.client
  region                             = local.region
  environment                        = var.environment
  client                             = local.client
  vpc_instance_tenancy               = var.vpc_instance_tenancy
  ssm_managed_instance_arn           = var.ssm_managed_instance_arn
  vpc_cidr                           = var.vpc_cidr
  additional_vpc_cidr                = var.additional_vpc_cidr
  subnet_short                       = var.subnet_short
  subnets_dmz                        = var.subnets_dmz
  subnets_internal                   = var.subnets_internal
  subnets_database                   = var.subnets_database
  subnets_approach                   = var.subnets_approach
  subnets_secure                     = var.subnets_secure
  subnets_workspaces                 = var.subnets_workspaces
  dmz_routes                         = var.dmz_routes
  internal_routes                    = var.internal_routes
  approach_routes                    = var.approach_routes
  secure_routes                      = var.secure_routes
  dmz_ingress_ports                  = var.dmz_egress_ports
  internal_ingress_ports             = var.internal_ingress_ports
  database_ingress_ports             = var.database_ingress_ports
  approach_ingress_ports             = var.approach_ingress_ports
  secure_ingress_ports               = var.secure_ingress_ports
  workspaces_ingress_ports           = var.workspaces_ingress_ports
  dmz_egress_ports                   = var.dmz_egress_ports
  internal_egress_ports              = var.internal_egress_ports
  database_egress_ports              = var.database_egress_ports
  approach_egress_ports              = var.approach_egress_ports
  secure_egress_ports                = var.secure_egress_ports
  workspaces_egress_ports            = var.workspaces_egress_ports
}

module "domain_controller" {
  source                                       = "../../templates/directory_services/domain_controller"
  client                                       = local.client
  profile                                      = local.client
  region                                       = local.region
  environment                                  = var.environment
  vpc_id                                       = module.core_network.vpc_id
  subnet_ids                                   = module.core_network.internal_subnet_ids
  domaincontroller_ami                         = var.domaincontroller_ami
  instance_type                                = var.instance_type
  domaincontroller_disk_size                   = var.domaincontroller_disk_size
  domaincontroller_ssh_key                     = var.domaincontroller_ssh_key
  key_pair_name                                = var.domaincontroller_ssh_key
  domaincontroller_securitygroup_ingress_ports = var.domaincontroller_securitygroup_ingress_ports
  domaincontroller_securitygroup_egress_ports  = var.domaincontroller_securitygroup_egress_ports
  crowd_strike_sg_id                            = module.core_services.crowd_strike_sg_id
}

module "core_services" {
  source                    = "../../core/core_services"
  client                    = local.client
  environment               = var.environment
  region                    = local.region
  vpc_id                    = module.core_network.vpc_id
  subnet_ids                = module.core_network.internal_subnet_ids
  internal_route_table_id   = module.core_network.internal_route_table_id
  pagerduty_integration_key = var.pagerduty_integration_key
  security_account_cloudtrail_bucket = var.security_account_cloudtrail_bucket
}

module "core_apps" {
  source                                                 = "../../core/core_apps"
  client                                                 = local.client
  environment                                            = var.environment
  region                                                 = local.region
  vpc_id                                                 = module.core_network.vpc_id
  subnet_ids                                             = module.core_network.internal_subnet_ids
  db_subnet_ids                                          = module.core_network.database_subnet_ids
  dmz_ids                                                = module.core_network.dmz_subnet_ids
  secure_node_subnet_ids                                 = []
  approach_node_subnet_ids                               = []
  eks_cluster_admin_ami                                  = var.eks_cluster_admin_ami
  eks_cluster_worker_node_ssh_key                        = var.eks_cluster_worker_node_ssh_key
  eks_version                                            = var.eks_version
  root_domain                                            = var.root_domain
  subdomain                                              = var.environment
  s3_kms_key_arn                                         = module.core_services.s3_kms_key_arn
  s3_log_bucket                                          = module.core_services.s3_log_bucket_name
  cluster_worker_node_autoscaling_min_size               = var.cluster_worker_node_autoscaling_min_size
  cluster_worker_node_autoscaling_desired_size           = var.cluster_worker_node_autoscaling_desired_size
  cluster_worker_node_autoscaling_max_size               = var.cluster_worker_node_autoscaling_max_size
  workspace_ip_ranges                                    = module.core_network.workspaces_subnet_cidr_blocks
  sns_topic                                              = module.core_services.sqs_dlq_sns_topic_arn
  es_retention_days                                      = var.es_retention_days
  jumpbox_ssh_key                                        = var.jumpbox_ssh_key
  pega_layer                                             = var.pega_layer
}

module "alcyon_backoffice" {
  source                            = "../../apps/alcyon_backoffice"
  region                            = local.region
  client                            = local.client
  environment                       = var.environment
  vpc_id                            = module.core_network.vpc_id
  db_cluster_parameter_group_family = var.db_cluster_parameter_group_family
  db_snapshot_identifier            = var.db_snapshot_identifier
  db_subnet_group_name              = module.core_network.db_subnet_group_name
  db_engine_version                 = var.db_engine_version
  db_instance_class                 = var.db_instance_class
  db_instance_count                 = var.db_instance_count
  s3_log_bucket                     = module.core_services.s3_log_bucket_name
  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
  eks_cluster_security_group_id     = module.core_apps.eks_cluster_security_group_id
  admin_security_group_id           = module.core_apps.eks_cluster_admin_security_group_id
  hosted_zone_id                    = module.core_apps.hosted_zone_id
  hosted_zone_name                  = module.core_apps.hosted_zone_name
  alarm_sns_topic_arn               = module.core_services.sqs_dlq_sns_topic_arn
  domain                            = var.root_domain
  cors_domain                       = "*.${var.environment}.${var.root_domain}"
  msk_ebs_size                      = var.msk_ebs_size
  msk_instance_type                 = var.msk_instance_type
  msk_version                       = var.msk_version
  db_subnet_ids                     = module.core_network.database_subnet_ids
  jumpbox_security_group_id         = module.core_apps.jumpbox_security_group_id #maybe we need to move jumpbox to core_services.....
  sns_topic                         = module.core_services.sqs_dlq_sns_topic_arn
  vpc_internal_cidr                 = module.core_network.internal_subnet_cidr_blocks
  certificate_arn                   = module.core_apps.certificate_arn
}

module "alcyon_backoffice_migration" {
  source                          = "../../apps/alcyon_backoffice_migration"
  client                          = local.client
  environment                     = var.environment
  region                            = local.region
  vpc_id                          = module.core_network.vpc_id
  hosted_zone_id                  = module.core_apps.hosted_zone_id
  hosted_zone_name                = module.core_apps.hosted_zone_name
  database_subnet_ids             = module.core_network.database_subnet_ids
  eks_cluster_security_group_id   = module.core_apps.eks_cluster_security_group_id
  s3_log_bucket                   = module.core_services.s3_log_bucket_name
  elasticache_engine_version      = var.alcyon_backoffice_migration_elasticache_engine_version
  elasticache_snapshot_identifier = var.alcyon_backoffice_migration_elasticache_snapshot_identifier
  elasticache_param_group_family  = var.alcyon_backoffice_migration_elasticache_param_group_family
  elasticache_node_type           = var.alcyon_backoffice_migration_elasticache_node_type
  elasticache_replica_count       = var.alcyon_backoffice_migration_elasticache_replica_count
  docdb_engine_version            = var.alcyon_backoffice_migration_docdb_engine_version
  docdb_param_group_family        = var.alcyon_backoffice_migration_docdb_param_group_family
  docdb_param_group_tls_enabled   = var.alcyon_backoffice_migration_docdb_param_group_tls_enabled
  docdb_snapshot_identifier       = var.alcyon_backoffice_migration_docdb_snapshot_identifier
  docdb_instance_class            = var.alcyon_backoffice_migration_docdb_instance_class
  docdb_instance_count            = var.alcyon_backoffice_migration_docdb_instance_count
  admin_security_group_id         = module.core_apps.eks_cluster_admin_security_group_id
  jumpbox_security_group_id       = module.core_apps.jumpbox_security_group_id
}

module "alcyon_backoffice_report" {
  source                            = "../../apps/alcyon_backoffice_report"
  region                            = local.region
  client                            = local.client
  environment                       = var.environment
  vpc_id                            = module.core_network.vpc_id
  db_cluster_parameter_group_family = var.alcyon_report_db_cluster_parameter_group_family
  db_snapshot_identifier            = var.alcyon_report_db_snapshot_identifier
  db_subnet_group_name              = module.core_network.db_subnet_group_name
  db_engine_version                 = var.alcyon_report_db_engine_version
  db_instance_class                 = var.alcyon_report_db_instance_class
  db_instance_count                 = var.alcyon_report_db_instance_count
  eks_cluster_security_group_id     = module.core_apps.eks_cluster_security_group_id
  admin_security_group_id           = module.core_apps.eks_cluster_admin_security_group_id
  hosted_zone_id                    = module.core_apps.hosted_zone_id
  hosted_zone_name                  = module.core_apps.hosted_zone_name
  jumpbox_security_group_id         = module.core_apps.jumpbox_security_group_id
}

module "alcyon_records_management" {
  source                            = "../../apps/alcyon_records_manager"
  region                            = local.region
  environment                       = var.environment
  client                            = local.client
  vpc_id                            = module.core_network.vpc_id
  db_subnet_group_name              = module.core_network.db_subnet_group_name
  db_engine_version                 = var.alcyon_records_manager_db_engine_version
  db_cluster_parameter_group_family = var.alcyon_records_manager_db_cluster_parameter_group_family
  db_snapshot_identifier            = var.alcyon_records_manager_db_snapshot_identifier
  db_instance_count                 = var.alcyon_records_manager_db_instance_count
  db_instance_class                 = var.alcyon_records_manager_db_instance_class
  s3_log_bucket                     = module.core_services.s3_log_bucket_name
  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
  eks_cluster_security_group_id     = module.core_apps.eks_cluster_security_group_id
  admin_security_group_id           = module.core_apps.eks_cluster_admin_security_group_id
  hosted_zone_id                    = module.core_apps.hosted_zone_id
  hosted_zone_name                  = module.core_apps.hosted_zone_name
  alarm_sns_topic_arn               = module.core_services.sqs_dlq_sns_topic_arn
  jumpbox_security_group_id         = module.core_apps.jumpbox_security_group_id
}

module "au_nt_custom" {
  source                            = "./modules/nt_custom"
  environment                       = var.environment
  client                            = local.client
  region                            = local.region
  certificate_arn                   = module.core_apps.certificate_arn
  sftp_subnet                       = module.core_network.internal_subnet_ids[0]
  hosted_zone_id                    = module.core_apps.hosted_zone_id
  hosted_zone_name                  = module.core_apps.hosted_zone_name
  vpc_id                            = module.core_network.vpc_id
  allowed_ips                       = var.allowed_ips
  efs_arn                           = module.core_apps.efs_arn
  efs_id                            = module.core_apps.efs_id
}

module "worker_policy" {
  source                            = "../../templates/worker_node_policy"
  environment                       = var.environment
  client                            = local.client
  region                            = local.region
  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
  kms_keys_list                     = concat( module.alcyon_backoffice.kms_key_list,
    module.alcyon_records_management.kms_key_list,
    module.alcyon_backoffice_migration.kms_key_list )
  s3_bucket_list                    = concat( module.alcyon_backoffice.s3_list,
    module.alcyon_records_management.s3_list,
    module.alcyon_backoffice_migration.s3_list )
  sqs_list                          = concat( module.alcyon_backoffice.sqs_list,
    module.alcyon_records_management.sqs_list )
}

module "it_service" {
  source                                = "../../templates/directory_services/it_service"
  client                                = local.client
  profile                               = local.client
  region                                = local.region
  environment                           = var.environment
  vpc_id                                = module.core_network.vpc_id
  subnet_ids                            = module.core_network.internal_subnet_ids
  itservice_ami                         = var.itservice_ami
  itservice_instance_type               = var.itservice_instance_type
  itservice_disk_size                   = var.itservice_disk_size
  itservice_ssh_key                     = var.itservice_ssh_key
  key_pair_name                         = var.itservice_ssh_key
  itservice_securitygroup_ingress_ports = var.itservice_securitygroup_ingress_ports
  itservice_securitygroup_egress_ports  = var.itservice_securitygroup_egress_ports
}

module "backup" {
  source         = "../../templates/backup"
  client         = local.client
  profile        = local.client
  region         = local.region
  iam_arn_prefix = local.iam_arn_prefix
  environment    = var.environment
}
