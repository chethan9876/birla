variable "environment" {}
variable "client" {}
variable "region" {}

variable "vpc_id" {}
variable "hosted_zone_name" {}
variable "hosted_zone_id" {}
variable "database_subnet_ids" {}
variable "eks_cluster_security_group_id" {}
variable "s3_log_bucket" {}

variable "elasticache_engine_version" {}
variable "elasticache_snapshot_identifier" {}
variable "elasticache_param_group_family" {}
variable "elasticache_node_type" {}
variable "elasticache_replica_count" {
  default = 2
}

variable "docdb_engine_version" {}
variable "docdb_param_group_family" {}
variable "docdb_param_group_tls_enabled" {
  default = "disabled"
}
variable "docdb_snapshot_identifier" {}
variable "docdb_instance_class" {}
variable "docdb_instance_count" {
  default = 2
}

variable "admin_security_group_id" {}
variable "jumpbox_security_group_id" {
  default = ""
}

variable "sns_topic" {
  default = ""
}
