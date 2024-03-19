locals {
  application = "alcyon-backoffice"
  client      = var.client
  environment = var.environment
  region      = var.region
  prefix      = "${local.environment}-${local.client}-filecatalyst"
}

variable "client" {}
variable "environment" {}
variable "region" {}
variable "vpc_id" {}
variable "iam_arn_prefix" {}
variable "internal_subnet_ids" {}
variable "ssh_key" {}
variable "sns_topic" {}
variable "hosted_zone_id" {}
variable "hosted_zone_name" {}
variable "jumpbox_security_group" {}
variable "certificate_arn" {}
variable "sftp_subnet" {}
variable "allowed_ips" {}
variable "efs_arn" {}
variable "efs_id" {}
variable "dmz_subnet" {}