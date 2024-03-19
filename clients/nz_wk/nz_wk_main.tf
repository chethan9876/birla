data "aws_caller_identity" "current" {}
locals {
  client         = "nz-wk"
  region         = "ap-southeast-2"
  iam_arn_prefix = "arn:aws"
  account_id     = data.aws_caller_identity.current.account_id
}

provider "aws" {
  profile = local.client
  region  = local.region
}

terraform {
  backend "s3" {}
}

module "core_network" {
  source                     = "../../core/core_network"
  profile                    = local.client
  region                     = local.region
  environment                = var.environment
  client                     = local.client
  vpc_instance_tenancy       = var.vpc_instance_tenancy
  ssm_managed_instance_arn   = var.ssm_managed_instance_arn
  subnet_short               = var.subnet_short
  additional_internal_routes = var.additional_internal_routes
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
  crowd_strike_sg_id                           = module.core_services.crowd_strike_sg_id
}

module "core_services" {
  source                             = "../../core/core_services"
  client                             = local.client
  environment                        = var.environment
  region                             = local.region
  vpc_id                             = module.core_network.vpc_id
  subnet_ids                         = module.core_network.internal_subnet_ids
  internal_route_table_id            = module.core_network.internal_route_table_id
  pagerduty_integration_key          = var.pagerduty_integration_key
  security_account_cloudtrail_bucket = var.security_account_cloudtrail_bucket
}

module "core_apps" {
  source                                       = "../../core/core_apps"
  client                                       = local.client
  environment                                  = var.environment
  region                                       = local.region
  vpc_id                                       = module.core_network.vpc_id
  subnet_ids                                   = module.core_network.internal_subnet_ids
  db_subnet_ids                                = module.core_network.database_subnet_ids
  dmz_ids                                      = module.core_network.dmz_subnet_ids
  secure_node_subnet_ids                       = []
  approach_node_subnet_ids                     = []
  eks_cluster_admin_ami                        = var.eks_cluster_admin_ami
  eks_cluster_worker_node_ssh_key              = var.eks_cluster_worker_node_ssh_key
  eks_version                                  = var.eks_version
  root_domain                                  = var.root_domain
  subdomain                                    = var.environment
  s3_kms_key_arn                               = module.core_services.s3_kms_key_arn
  s3_log_bucket                                = module.core_services.s3_log_bucket_name
  cluster_worker_node_autoscaling_desired_size = var.cluster_worker_node_autoscaling_desired_size
  cluster_worker_node_autoscaling_max_size     = var.cluster_worker_node_autoscaling_max_size
  workspace_ip_ranges                          = module.core_network.workspaces_subnet_cidr_blocks
  sns_topic                                    = module.core_services.sqs_dlq_sns_topic_arn
  es_retention_days                            = var.es_retention_days
  jumpbox_ssh_key                              = var.jumpbox_ssh_key
  pega_layer                                   = var.pega_layer
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
  api_whitelist_ips                 = var.allowed_ips
}

//module "alcyon_backoffice_report" {
//  source                            = "../../apps/alcyon_backoffice_report"
//  region                            = local.region
//  client                            = local.client
//  environment                       = var.environment
//  vpc_id                            = module.core_network.vpc_id
//  db_cluster_parameter_group_family = var.alcyon_report_db_cluster_parameter_group_family
//  db_snapshot_identifier            = var.alcyon_report_db_snapshot_identifier
//  db_subnet_group_name              = module.core_network.db_subnet_group_name
//  db_engine_version                 = var.alcyon_report_db_engine_version
//  db_instance_class                 = var.alcyon_report_db_instance_class
//  db_instance_count                 = var.alcyon_report_db_instance_count
//  eks_cluster_security_group_id     = module.core_apps.eks_cluster_security_group_id
//  admin_security_group_id           = module.core_apps.eks_cluster_admin_security_group_id
//  hosted_zone_id                    = module.core_apps.hosted_zone_id
//  hosted_zone_name                  = module.core_apps.hosted_zone_name
//  jumpbox_security_group_id         = module.core_apps.jumpbox_security_group_id
//}
//
//module "alcyon_records_management" {
//  source                            = "../../apps/alcyon_records_manager"
//  region                            = local.region
//  environment                       = var.environment
//  client                            = local.client
//  vpc_id                            = module.core_network.vpc_id
//  db_subnet_group_name              = module.core_network.db_subnet_group_name
//  db_engine_version                 = var.alcyon_records_manager_db_engine_version
//  db_cluster_parameter_group_family = var.alcyon_records_manager_db_cluster_parameter_group_family
//  db_snapshot_identifier            = var.alcyon_records_manager_db_snapshot_identifier
//  db_instance_count                 = var.alcyon_records_manager_db_instance_count
//  db_instance_class                 = var.alcyon_records_manager_db_instance_class
//  s3_log_bucket                     = module.core_services.s3_log_bucket_name
//  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
//  eks_cluster_security_group_id     = module.core_apps.eks_cluster_security_group_id
//  admin_security_group_id           = module.core_apps.eks_cluster_admin_security_group_id
//  hosted_zone_id                    = module.core_apps.hosted_zone_id
//  hosted_zone_name                  = module.core_apps.hosted_zone_name
//  alarm_sns_topic_arn               = module.core_services.sqs_dlq_sns_topic_arn
//  jumpbox_security_group_id         = module.core_apps.jumpbox_security_group_id
//}

module "alcyon_control" {
  source                            = "../../apps/alcyon_control"
  region                            = local.region
  client                            = local.client
  environment                       = var.environment
  vpc_id                            = module.core_network.vpc_id
  db_cluster_parameter_group_family = var.alcyon_control_db_cluster_parameter_group_family
  db_snapshot_identifier            = var.alcyon_control_db_snapshot_identifier
  db_engine_version                 = var.alcyon_control_db_engine_version
  db_instance_class                 = var.alcyon_control_db_instance_class
  db_instance_count                 = var.alcyon_control_db_instance_count
  db_subnet_group_name              = module.core_network.db_subnet_group_name
  s3_log_bucket                     = module.core_services.s3_log_bucket_name
  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
  eks_cluster_security_group_id     = module.core_apps.eks_cluster_security_group_id
  admin_security_group_id           = module.core_apps.eks_cluster_admin_security_group_id
  hosted_zone_id                    = module.core_apps.hosted_zone_id
  hosted_zone_name                  = module.core_apps.hosted_zone_name
  jumpbox_security_group_id         = module.core_apps.jumpbox_security_group_id
}

module "alcyon_express" {
  source                            = "../../apps/alcyon_express"
  region                            = local.region
  client                            = local.client
  environment                       = var.environment
  vpc_id                            = module.core_network.vpc_id
  db_cluster_parameter_group_family = var.alcyon_express_db_cluster_parameter_group_family
  db_snapshot_identifier            = var.alcyon_express_db_snapshot_identifier
  db_engine_version                 = var.alcyon_express_db_engine_version
  db_instance_class                 = var.alcyon_express_db_instance_class
  db_instance_count                 = var.alcyon_express_db_instance_count
  db_subnet_group_name              = module.core_network.db_subnet_group_name
  s3_log_bucket                     = module.core_services.s3_log_bucket_name
  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
  eks_cluster_security_group_id     = module.core_apps.eks_cluster_security_group_id
  admin_security_group_id           = module.core_apps.eks_cluster_admin_security_group_id
  hosted_zone_id                    = module.core_apps.hosted_zone_id
  hosted_zone_name                  = module.core_apps.hosted_zone_name
  jumpbox_security_group_id         = module.core_apps.jumpbox_security_group_id
  db_subnet_ids                     = module.core_network.database_subnet_ids
  internal_subnet_ids               = module.core_network.internal_subnet_ids
  iam_arn_prefix                    = "arn:aws"
  msk_ebs_size                      = var.msk_ebs_size
  msk_instance_type                 = var.msk_instance_type
  msk_version                       = var.msk_version
  sns_topic                         = module.core_services.sqs_dlq_sns_topic_arn
  es_snapshot_s3                    = module.core_apps.es_snapshot_s3_bucket
  es_s3_kms_key_arn                 = module.core_services.s3_kms_key_arn
}

module "wk_custom" {
  source                 = "./modules/wk_custom"
  region                 = local.region
  client                 = local.client
  environment            = var.environment
  vpc_id                 = module.core_network.vpc_id
  internal_subnet_ids    = module.core_network.internal_subnet_ids
  sftp_subnet            = module.core_network.internal_subnet_ids[0]
  allowed_ips            = var.allowed_ips
  efs_arn                = module.core_apps.efs_arn
  efs_id                 = module.core_apps.efs_id
  certificate_arn        = module.core_apps.certificate_arn
  hosted_zone_id         = module.core_apps.hosted_zone_id
  hosted_zone_name       = module.core_apps.hosted_zone_name
  sns_topic              = module.core_services.sqs_dlq_sns_topic_arn
  ssh_key                = var.eks_cluster_worker_node_ssh_key
  iam_arn_prefix         = local.iam_arn_prefix
  jumpbox_security_group = module.core_apps.jumpbox_security_group_id
  dmz_subnet             = module.core_network.dmz_subnet_ids[0]
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

module "worker_policy" {
  source                            = "../../templates/worker_node_policy"
  environment                       = var.environment
  client                            = local.client
  region                            = local.region
  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
  kms_keys_list = concat(module.alcyon_control.kms_key_list,
  module.alcyon_backoffice.kms_key_list)
  s3_bucket_list = concat(module.alcyon_control.s3_list,
  module.alcyon_backoffice.s3_list)
  sqs_list = concat(module.alcyon_backoffice.sqs_list)
}