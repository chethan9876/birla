locals {
  client = var.client
  application = "alcyon-backoffice"
  region = var.region
  environment = lower(trimspace(var.environment))
  prefix = "${local.environment}-${local.client}-${local.application}"
}

variable "environment" {}
variable "client" {}
variable "region" {}
variable "vpc_id" {}
variable "certificate_arn" {}
variable "hosted_zone_id" {}
variable "hosted_zone_name" {}
variable "dmz_subnet" {}
//variable "sftp_subnet" {}
variable "allowed_ips" {}
variable "efs_arn" {}
variable "efs_id" {}
