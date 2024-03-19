variable "environment" {}
variable "pega_layer" {
  default = "WA"
}


#core_network
variable "subnet_short" {}
variable "vpc_instance_tenancy" {}
variable "ssm_managed_instance_arn" {}

variable "additional_internal_ingress_ports" {type = list(object({
  rule_no = number
  protocol = string
  rule_action = string
  cidr_block = string
  from_port = number
  to_port = number
}))}
variable "additional_internal_egress_ports" {type = list(object({
  rule_no = number
  protocol = string
  rule_action = string
  cidr_block = string
  from_port = number
  to_port = number
}))}
variable "additional_internal_routes" {
  default = []
}

variable "allowed_ips" {}
variable "vpce_svc_allowed_accounts" {
  default = []
}

variable "db_engine_version" {}
variable "db_cluster_parameter_group_family" {}
variable "db_snapshot_identifier" {}
variable "db_instance_class" {}
variable "db_instance_count" {}

variable "alcyon_report_db_engine_version" {}
variable "alcyon_report_db_cluster_parameter_group_family" {}
variable "alcyon_report_db_snapshot_identifier" {}
variable "alcyon_report_db_instance_class" {}
variable "alcyon_report_db_instance_count" {}

variable "alcyon_backoffice_migration_elasticache_engine_version" {}
variable "alcyon_backoffice_migration_elasticache_snapshot_identifier" {}
variable "alcyon_backoffice_migration_elasticache_param_group_family" {}
variable "alcyon_backoffice_migration_elasticache_node_type" {}
variable "alcyon_backoffice_migration_elasticache_replica_count" {}
variable "alcyon_backoffice_migration_docdb_engine_version" {}
variable "alcyon_backoffice_migration_docdb_param_group_family" {}
variable "alcyon_backoffice_migration_docdb_snapshot_identifier" {}
variable "alcyon_backoffice_migration_docdb_instance_class" {}
variable "alcyon_backoffice_migration_docdb_instance_count" {}

variable "alcyon_records_manager_db_engine_version" {}
variable "alcyon_records_manager_db_cluster_parameter_group_family" {}
variable "alcyon_records_manager_db_snapshot_identifier" {}
variable "alcyon_records_manager_db_instance_count" {}
variable "alcyon_records_manager_db_instance_class" {}

variable "msk_version" {}
variable "msk_instance_type" {}
variable "msk_ebs_size" {}

//core_apps
variable "eks_cluster_admin_ami" {}
variable "eks_cluster_worker_node_ssh_key" {}
variable "eks_cluster_admin_additional_ingress_security_group_id" {}
variable "eks_version" {}
variable "cluster_worker_node_autoscaling_desired_size" {}
variable "cluster_worker_node_autoscaling_max_size" {}
variable "root_domain" {}
variable "jumpbox_ssh_key" {}
variable "es_retention_days" {
  default = 45
}

//core_services
variable "pagerduty_integration_key" {}
variable "security_account_cloudtrail_bucket" {}

//domain_controller
variable "domaincontroller_ami" {}
variable "instance_type" {}
variable "domaincontroller_disk_size" {}
variable "domaincontroller_securitygroup_ingress_ports" {type = list(object({
  protocol = string
  from_port = number
  cidr_blocks = list(string)
  to_port = number
  security_groups = list(string)
  description = string

}))}
variable "domaincontroller_securitygroup_egress_ports" {type = list(object({
  protocol = string
  from_port = number
  cidr_blocks = list(string)
  to_port = number
  security_groups = list(string)
  description = string

}))}
variable "domaincontroller_ssh_key" {}

//adconnector
variable "activedirectoryname" {}
variable "adconnector_username" {}
variable "adconnector_password" {}
variable "adconnectorsize" {}

//it_service
variable "itservice_ami" {}
variable "itservice_instance_type" {}
variable "itservice_disk_size" {}
variable "itservice_securitygroup_ingress_ports" {type = list(object({
  protocol = string
  from_port = number
  cidr_blocks = list(string)
  to_port = number
  security_groups = list(string)
  description = string

}))}
variable "itservice_securitygroup_egress_ports" {type = list(object({
  protocol = string
  from_port = number
  cidr_blocks = list(string)
  to_port = number
  security_groups = list(string)
  description = string

}))}
variable "itservice_ssh_key" {}

variable "dotApiExternalID" {}
variable "assumer_roles" {}