variable "region" {}
variable "environment" {}
variable "client" {}
variable "cors_domain" {}

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


variable "eks_cluster_worker_node_role_name" {}
variable "eks_cluster_security_group_id" {}
variable "admin_security_group_id" {}
variable "jumpbox_security_group_id" {
  default = ""
}

variable "hosted_zone_name" {}
variable "hosted_zone_id" {}
variable "s3_log_bucket" {}