locals {
  application = "core-apps"
  client      = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  prefix      = "${local.environment}-${local.client}-${local.application}"
}

provider aws {
  profile = var.client
  region = var.region
}

provider aws {
  alias = "route53"
  profile = var.client == "us-govcloud" ? "us-govcloud-parent" : var.client
  region = "us-east-1"
}

module "eks" {
  source                      = "../../templates/eks"
  environment                 = local.environment
  region                      = var.region
  client                      = local.client
  cluster_admin_ami           = var.eks_cluster_admin_ami
  cluster_worker_node_ssh_key = var.eks_cluster_worker_node_ssh_key

  vpc_id                   = var.vpc_id
  dmz_ids                  = var.dmz_ids
  subnet_ids               = var.subnet_ids
  secure_node_subnet_ids   = var.secure_node_subnet_ids
  approach_node_subnet_ids = var.approach_node_subnet_ids

  efs_dns_name                                       = module.efs.efs_dns_name
  efs_file_system_security_group_id                  = module.efs.efs_security_group_id
  root_domain                                        = var.root_domain
  hosted_zone_name                                   = module.hosted_zone.hosted_zone_name
  hosted_zone_id                                     = module.hosted_zone.hosted_zone_id
  jumpbox_ingress_security_group_id                  = aws_security_group.jumpbox_security_group.id
  hosted_zone_arn                                    = module.hosted_zone.hosted_zone_arn
  iam_arn_prefix                                     = var.iam_arn_prefix
  cluster_worker_node_autoscaling_min_size           = var.cluster_worker_node_autoscaling_min_size
  cluster_worker_node_autoscaling_desired_size       = var.cluster_worker_node_autoscaling_desired_size
  cluster_worker_node_autoscaling_max_size           = var.cluster_worker_node_autoscaling_max_size
  workspace_ip_ranges                                = var.workspace_ip_ranges
  eks_version                                        = var.eks_version
  sns_topic                                          = var.sns_topic
  pega_layer                                         = var.pega_layer
  additional_user_data                               = var.additional_user_data
}

module "elasticsearch_kms_key" {
  source      = "../../templates/kms"
  environment = var.environment
  client      = local.client
  application = local.application
  name        = "elasticsearch"
}

module "es_snapshot_s3_bucket" {
  source             = "../../templates/s3"
  application        = local.application
  client             = local.client
  environment        = local.environment
  aws_kms_s3_key_arn = var.s3_kms_key_arn
  s3_log_bucket      = var.s3_log_bucket
  name               = "es-snapshot"
}

module "elasticsearch_logs" {
  source = "../../templates/elasticsearch"

  environment                         = local.environment
  region                              = var.region
  client                              = local.client
  iam_arn_prefix                      = var.iam_arn_prefix
  application                         = "logs"
  eks_cluster_admin_security_group_id = module.eks.cluster_admin_security_group_id
  eks_cluster_security_group_id       = module.eks.cluster_security_group_id
  es_kms_key_arn                      = module.elasticsearch_kms_key.kms_key_arn
  s3_kms_key_arn                      = var.s3_kms_key_arn
  s3_log_bucket                       = var.s3_log_bucket
  es_instance_count                   = var.es_instance_count
  subnet_ids                          = slice(tolist(var.subnet_ids), 0, var.es_instance_count)
  vpc_id                              = var.vpc_id
  hosted_zone_id                      = module.hosted_zone.hosted_zone_id
  hosted_zone_name                    = module.hosted_zone.hosted_zone_name
  es_snapshot_s3_bucket               = module.es_snapshot_s3_bucket.s3_bucket_name
  sns_topic                           = var.sns_topic
  es_retention_days                   = var.es_retention_days
  jumpbox_security_group_id           = aws_security_group.jumpbox_security_group.id
}

//TODO: TI-43: try tunnelling to apply delete policy
#data template_file "es_indexes_delete_policy" {
#  template = file("${path.module}/resources/es_update_ism_policy.sh")
#  vars = {
#    es_url = module.elasticsearch_logs.es_endpoint
#    indexes_policy = file("${path.module}/resources/es_indexes_delete_policy.json")
#  }
#}
#
#module "elasticsearch_ssm" {
#  source = "../../templates/ssm"
#  environment = var.environment
#  client = local.client
#  application = local.application
#  name = "elasticsearch"
#  ssm_content_command = data.template_file.es_indexes_delete_policy.rendered
#  ssm_content_description = "Add ism policy to delete indexes after 90 days"
#  ssm_association_tag = module.eks.cluster_admin_tag_name
#}

module "efs_kms_key" {
  source      = "../../templates/kms"
  environment = var.environment
  client      = local.client
  application = local.application
  name        = "efs"
}

module "efs" {
  source           = "../../templates/efs"
  environment      = var.environment
  client           = local.client
  application      = local.application
  hosted_zone_name = module.hosted_zone.hosted_zone_name
  hosted_zone_id   = module.hosted_zone.hosted_zone_id
  vpc_id           = var.vpc_id
  kms_key_id       = module.efs_kms_key.kms_key_arn
  mount_targets    = var.subnet_ids
}

module "hosted_zone" {
  source      = "../../templates/route53_hosted_zone"
  environment = var.environment
  client      = local.client
  application = local.application
  root_domain = var.root_domain
  subdomain   = var.subdomain
  region      = var.region
}

module "acm" {
  source         = "../../templates/acm"
  client         = local.client
  domain_name    = module.hosted_zone.hosted_zone_name
  environment    = var.environment
  hosted_zone_id = module.hosted_zone.hosted_zone_id
}