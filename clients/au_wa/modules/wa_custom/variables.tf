locals {
  client = var.client
  application = "alcyon-backoffice"
  region = var.region
  environment = lower(trimspace(var.environment))
  prefix = "${local.environment}-${local.client}-${local.application}"
  authorisation = "NONE"
}

variable "environment" {}
variable "client" {}
variable "region" {}
variable "alarm_sns_topic_arn" {}
variable "eks_cluster_worker_node_role_name" {}
variable "vpc_id" {}
variable "certificate_arn" {}
variable "hosted_zone_id" {}
variable "hosted_zone_name" {}
variable "dmz_subnet" {}
variable "allowed_ips" {}
variable "s3_log_bucket_name" {}
variable "efs_arn" {}
variable "efs_id" {}
variable "internal_subnet_ids" {}
variable "vpce_svc_allowed_accounts" {
  default = []
}
variable "domain" {}
variable "dotApiExternalID" {}

variable "assumer_roles" {}