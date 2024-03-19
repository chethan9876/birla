variable "region" {}
variable "environment" {}
variable "client" {}

variable "vpc_id" {}

variable "db_engine_version" {}
variable "db_subnet_group_name" {}
variable "db_cluster_parameter_group_family" {}
variable "db_snapshot_identifier" {}
variable "db_instance_class" {}
variable "db_instance_count" {
  default = 2
}
variable "db_performance_insights_enabled" {
  default = true
}

variable "s3_log_bucket" {}

variable "eks_cluster_worker_node_role_name" {}
variable "eks_cluster_security_group_id" {}
variable "admin_security_group_id" {}
variable "jumpbox_security_group_id" {
  default = ""
}

variable "hosted_zone_name" {}
variable "hosted_zone_id" {}

variable "internal_subnet_ids" {}
variable "db_subnet_ids" {}
variable "iam_arn_prefix" {}
variable "sns_topic" {}

variable "msk_ebs_size" {}
variable "msk_instance_type" {}
variable "msk_version" {}

variable "es_snapshot_s3" {}
variable "es_s3_kms_key_arn" {}
variable "es_retention_days" {
  default = 1000
}