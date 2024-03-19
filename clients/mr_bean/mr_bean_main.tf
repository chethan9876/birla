data "aws_caller_identity" "current" {}
locals {
  client = "mr-bean"
  region = "us-west-2"
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
  source                              = "../../core/core_network"
  profile                             = local.client
  region                              = local.region
  environment                         = var.environment
  client                              = local.client
  vpc_instance_tenancy                = var.vpc_instance_tenancy
  ssm_managed_instance_arn            = var.ssm_managed_instance_arn
  additional_internal_egress_ports    = var.additional_internal_egress_ports
  additional_internal_ingress_ports   = var.additional_internal_ingress_ports
  additional_workspaces_egress_ports  = var.additional_workspaces_egress_ports
  additional_workspaces_ingress_ports = var.additional_workspaces_ingress_ports
  additional_internal_routes          = var.additional_internal_routes
  additional_workspaces_routes        = var.additional_workspaces_routes
  additional_approach_routes          = var.additional_approach_routes
  additional_dmz_routes               = var.additional_dmz_routes
  additional_secure_routes            = var.additional_secure_routes
  subnet_short                        = var.subnet_short
}

module "domain_controller" {
  source                                        = "../../templates/directory_services/domain_controller"
  client                                        = local.client
  profile                                       = local.client
  region                                        = local.region
  environment                                   = var.environment
  vpc_id                                        = module.core_network.vpc_id
  subnet_ids                                    = module.core_network.internal_subnet_ids
  domaincontroller_ami                          = var.domaincontroller_ami
  instance_type                                 = var.instance_type
  domaincontroller_disk_size                    = var.domaincontroller_disk_size
  domaincontroller_ssh_key                      = var.domaincontroller_ssh_key
  key_pair_name                                 = var.domaincontroller_ssh_key
  domaincontroller_securitygroup_ingress_ports  = var.domaincontroller_securitygroup_ingress_ports
  domaincontroller_securitygroup_egress_ports   = var.domaincontroller_securitygroup_egress_ports
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
  approach_node_subnet_ids                               = module.core_network.approach_subnet_ids
  eks_cluster_admin_ami                                  = var.eks_cluster_admin_ami
  eks_cluster_worker_node_ssh_key                        = var.eks_cluster_worker_node_ssh_key
  eks_version                                            = var.eks_version
  root_domain                                            = var.root_domain
  subdomain                                              = var.environment
  s3_kms_key_arn                                         = module.core_services.s3_kms_key_arn
  s3_log_bucket                                          = module.core_services.s3_log_bucket_name
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
  jumpbox_security_group_id         = module.core_apps.jumpbox_security_group_id
  sns_topic                         = module.core_services.sqs_dlq_sns_topic_arn
  vpc_internal_cidr                 = module.core_network.internal_subnet_cidr_blocks
  certificate_arn                   = module.core_apps.certificate_arn
}

module "alcyon_backoffice_migration" {
  source                            = "../../apps/alcyon_backoffice_migration"
  client                            = local.client
  environment                       = var.environment
  region                            = local.region
  vpc_id                            = module.core_network.vpc_id
  hosted_zone_id                    = module.core_apps.hosted_zone_id
  hosted_zone_name                  = module.core_apps.hosted_zone_name
  database_subnet_ids               = module.core_network.database_subnet_ids
  eks_cluster_security_group_id     = module.core_apps.eks_cluster_security_group_id
  s3_log_bucket                     = module.core_services.s3_log_bucket_name
  elasticache_engine_version        = var.alcyon_backoffice_migration_elasticache_engine_version
  elasticache_snapshot_identifier   = var.alcyon_backoffice_migration_elasticache_snapshot_identifier
  elasticache_param_group_family    = var.alcyon_backoffice_migration_elasticache_param_group_family
  elasticache_node_type             = var.alcyon_backoffice_migration_elasticache_node_type
  elasticache_replica_count         = var.alcyon_backoffice_migration_elasticache_replica_count
  docdb_engine_version              = var.alcyon_backoffice_migration_docdb_engine_version
  docdb_param_group_family          = var.alcyon_backoffice_migration_docdb_param_group_family
  docdb_snapshot_identifier         = var.alcyon_backoffice_migration_docdb_snapshot_identifier
  docdb_instance_class              = var.alcyon_backoffice_migration_docdb_instance_class
  docdb_instance_count              = var.alcyon_backoffice_migration_docdb_instance_count
  admin_security_group_id           = module.core_apps.eks_cluster_admin_security_group_id
  jumpbox_security_group_id         = module.core_apps.jumpbox_security_group_id
  sns_topic                         = module.core_services.sqs_dlq_sns_topic_arn
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

module "alcyon_field_service" {
  source                            = "../../apps/alcyon_field_service"
  region                            = local.region
  client                            = local.client
  environment                       = var.environment
  vpc_id                            = module.core_network.vpc_id
  db_cluster_parameter_group_family = var.alcyon_field_service_db_cluster_parameter_group_family
  db_snapshot_identifier            = var.alcyon_field_service_db_snapshot_identifier
  db_subnet_group_name              = module.core_network.db_subnet_group_name
  db_engine_version                 = var.alcyon_field_service_db_engine_version
  db_instance_class                 = var.alcyon_field_service_db_instance_class
  db_instance_count                 = var.alcyon_field_service_db_instance_count
  s3_log_bucket                     = module.core_services.s3_log_bucket_name
  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
  eks_cluster_security_group_id     = module.core_apps.eks_cluster_security_group_id
  admin_security_group_id           = module.core_apps.eks_cluster_admin_security_group_id
  hosted_zone_id                    = module.core_apps.hosted_zone_id
  hosted_zone_name                  = module.core_apps.hosted_zone_name
  cors_domain                       = "*.${var.environment}.${var.root_domain}"
  jumpbox_security_group_id         = module.core_apps.jumpbox_security_group_id
}

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

module "alcyon_pega_deployment" {
  source                            = "../../apps/alcyon_pega_deployment"
  region                            = local.region
  client                            = local.client
  environment                       = var.environment
  vpc_id                            = module.core_network.vpc_id
  db_cluster_parameter_group_family = var.alcyon_pega_deployment_db_cluster_parameter_group_family
  db_snapshot_identifier            = var.alcyon_pega_deployment_db_snapshot_identifier
  db_subnet_group_name              = module.core_network.db_subnet_group_name
  db_engine_version                 = var.alcyon_pega_deployment_db_engine_version
  db_instance_class                 = var.alcyon_pega_deployment_db_instance_class
  db_instance_count                 = var.alcyon_pega_deployment_db_instance_count
  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
  eks_cluster_security_group_id     = module.core_apps.eks_cluster_security_group_id
  admin_security_group_id           = module.core_apps.eks_cluster_admin_security_group_id
  hosted_zone_id                    = module.core_apps.hosted_zone_id
  hosted_zone_name                  = module.core_apps.hosted_zone_name
  domain                            = var.root_domain
  cors_domain                       = "*.${var.environment}.${var.root_domain}"
  db_subnet_ids                     = module.core_network.database_subnet_ids
  jumpbox_security_group_id         = module.core_apps.jumpbox_security_group_id

  vpc_internal_cidr                 = module.core_network.internal_subnet_cidr_blocks
  certificate_arn                   = module.core_apps.certificate_arn
}

module "worker_policy" {
  source = "../../templates/worker_node_policy"
  environment = var.environment
  client = local.client
  region = local.region
  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
  kms_keys_list = concat( module.alcyon_backoffice.kms_key_list,
      module.alcyon_control.kms_key_list,
      module.alcyon_field_service.kms_key_list,
      module.alcyon_records_management.kms_key_list,
      module.alcyon_backoffice_migration.kms_key_list,
      module.au_nsw_custom.kms_key_list,
      module.ca_calgary_transformr.kms_key_list,
      module.ca_wetaskiwin_custom.kms_key_list,
      module.ca_sk_custom.kms_key_list,
      module.us_custom.kms_key_list,
      module.mr_bean_custom.kms_key_list)
  s3_bucket_list = ["${local.iam_arn_prefix}:s3:::tst-mr-bean-*"]
  sqs_list = ["${local.iam_arn_prefix}:sqs:${local.region}:${local.account_id}:tst-mr-bean-*"]
}

module "ca_calgary_transformr" {
  source = "../ca_calgary/modules/calgary_transformr"
  environment = var.environment
  client = local.client
  region = local.region
  s3_log_bucket_name = module.core_services.s3_log_bucket_name
  alarm_sns_topic_arn = module.core_services.sqs_dlq_sns_topic_arn
  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
}

module "au_nsw_custom" {
  source = "../au_nsw/modules/nsw_custom"
  environment = var.environment
  client = local.client
  region = local.region
  alarm_sns_topic_arn = module.core_services.sqs_dlq_sns_topic_arn
  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
}

module "au_wa_custom" {
  source = "../au_wa/modules/wa_custom"
  environment = var.environment
  client = local.client
  region = local.region
  alarm_sns_topic_arn = module.core_services.sqs_dlq_sns_topic_arn
  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
  certificate_arn = module.core_apps.certificate_arn
  dmz_subnet = module.core_network.dmz_subnet_ids[0]
  hosted_zone_id = module.core_apps.hosted_zone_id
  hosted_zone_name = module.core_apps.hosted_zone_name
  vpc_id = module.core_network.vpc_id
  allowed_ips = ["103.87.254.138/32"]
  s3_log_bucket_name = module.core_services.s3_log_bucket_name
  efs_arn = module.core_apps.efs_arn
  efs_id = module.core_apps.efs_id
  internal_subnet_ids = module.core_network.internal_subnet_ids
  domain = var.root_domain
  dotApiExternalID = "AlcyonTrustKey"
  assumer_roles = ["arn:aws:iam::769454653760:role/Role_1_Dev_Account"]
}

module "ca_wetaskiwin_custom" {
  source = "../ca_wetaskiwin/modules/wetaskiwin_custom"
  environment = var.environment
  client = local.client
  region = local.region
  alarm_sns_topic_arn = module.core_services.sqs_dlq_sns_topic_arn
  s3_log_bucket_name = module.core_services.s3_log_bucket_name
  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
}

module "ca_sk_custom" {
  source = "../ca_sk/modules/saskatchewan_custom"
  environment = var.environment
  client = local.client
  region = local.region
  alarm_sns_topic_arn = module.core_services.sqs_dlq_sns_topic_arn
  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
}

module "us_custom" {
  source = "../us_govcloud/modules/govcloud_custom"
  environment = var.environment
  client = local.client
  region = local.region
  alarm_sns_topic_arn = module.core_services.sqs_dlq_sns_topic_arn
  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
}

module "mr_bean_custom" {
  source = "./modules/testing_custom"
  environment = var.environment
  client = local.client
  region = local.region
  alarm_sns_topic_arn = module.core_services.sqs_dlq_sns_topic_arn
  eks_cluster_worker_node_role_name = module.core_apps.eks_cluster_worker_node_role_name
  s3_log_bucket_name = module.core_services.s3_log_bucket_name
}

module "adconnector" {
  source                                        = "../../templates/directory_services/adconnector"
  activedirectoryname                           = var.activedirectoryname
  adconnector_username                          = var.adconnector_username
  adconnector_password                          = var.adconnector_password
  vpc_id                                        = module.core_network.vpc_id
  adconnectorsize                               = var.adconnectorsize
  ad_dns                                        = var.ad_dns
  subnet_ids                                    = var.adconnector_subnets
}

module "route53_endpoint" {
  source                                        = "../../templates/route53_endpoint"
  environment                                   = var.environment
  client                                        = local.client
  profile                                       = local.client
  region                                        = local.region
  vpc_id                                        = module.core_network.vpc_id
  endpoint_subnets                              = concat(module.core_network.internal_subnet_ids, module.core_network.workspaces_subnet_ids)
}

module "route53_resolver_rule" {
  source                                        = "../../templates/route53_resolver_rule"
  environment                                   = var.environment
  client                                        = local.client
  profile                                       = local.client
  region                                        = local.region
  description                                   = var.description
  domain_name                                   = var.domain_name
  resolver_endpoint_id                          = module.route53_endpoint.route53_endpoint_outbound
  target_ip1                                    = var.target_ip1
}

module "route53_resolver_rule_association" {
  source = "../../templates/route53_resolver_rule_association"
  environment                                   = var.environment
  client                                        = local.client
  profile                                       = local.client
  region                                        = local.region
  resolver_rule_id                              = module.route53_resolver_rule.route53_resolver_rule
  vpc_id                                        = module.core_network.vpc_id
}

module "it_service" {
  source                                        = "../../templates/directory_services/it_service"
  client                                        = local.client
  profile                                       = local.client
  region                                        = local.region
  environment                                   = var.environment
  vpc_id                                        = module.core_network.vpc_id
  subnet_ids                                    = module.core_network.internal_subnet_ids
  itservice_ami                                 = var.itservice_ami
  itservice_instance_type                       = var.itservice_instance_type
  itservice_disk_size                           = var.itservice_disk_size
  itservice_ssh_key                             = var.itservice_ssh_key
  key_pair_name                                 = var.itservice_ssh_key
  itservice_securitygroup_ingress_ports         = var.itservice_securitygroup_ingress_ports
  itservice_securitygroup_egress_ports          = var.itservice_securitygroup_egress_ports
}

module "workspaces" {
  source = "../../templates/workspaces"
  client                                        = local.client
  profile                                       = local.client
  region                                        = local.region
  environment                                   = var.environment
  vpc_id                                        = module.core_network.vpc_id
  aws_directory_service_directory               = module.adconnector.directory_id
  subnet_ids                                    = module.core_network.workspaces_subnet_ids
  workspaces_DefaultRole                        = var.workspaces_DefaultRole
  default_ou                                    = var.default_ou
  workspaces_securitygroup_ingress_ports        = var.workspaces_securitygroup_ingress_ports
  workspaces_securitygroup_egress_ports         = var.workspaces_securitygroup_egress_ports
//  workspaces_ip_group_rule1_source              = var.workspaces_ip_group_rule1_source
//  workspaces_ip_group_rule1_description         = var.workspaces_ip_group_rule1_description
//  workspaces_ip_group_rule2_source              = var.workspaces_ip_group_rule2_source
//  workspaces_ip_group_rule2_description         = var.workspaces_ip_group_rule2_description
//  workspaces_ip_group_rule3_source              = "10.255.255.255/32"
//  workspaces_ip_group_rule3_description         = ""
  local_admins                                  = true
}

module "backup" {
  source                                        = "../../templates/backup"
  client                                        = local.client
  profile                                       = local.client
  region                                        = local.region
  iam_arn_prefix                                = local.iam_arn_prefix
  environment                                   = var.environment
}
