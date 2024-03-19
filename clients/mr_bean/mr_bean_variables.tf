variable "environment" {}
variable "pega_layer" {
  default = "USA"
}


#core_network
variable "subnet_short" {}
variable "vpc_instance_tenancy" {}
variable "ssm_managed_instance_arn" {}

variable "additional_internal_routes" {}
variable "additional_workspaces_routes" {}
variable "additional_approach_routes" {}
variable "additional_dmz_routes" {}
variable "additional_secure_routes" {}

variable "additional_internal_ingress_ports" {}
variable "additional_internal_egress_ports" {}
variable "additional_workspaces_egress_ports" {}
variable "additional_workspaces_ingress_ports" {}

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

variable "alcyon_field_service_db_engine_version" {}
variable "alcyon_field_service_db_cluster_parameter_group_family" {}
variable "alcyon_field_service_db_snapshot_identifier" {}
variable "alcyon_field_service_db_instance_class" {}
variable "alcyon_field_service_db_instance_count" {}

variable "alcyon_control_db_engine_version" {}
variable "alcyon_control_db_cluster_parameter_group_family" {}
variable "alcyon_control_db_snapshot_identifier" {}
variable "alcyon_control_db_instance_class" {}
variable "alcyon_control_db_instance_count" {}

variable "alcyon_records_manager_db_engine_version" {}
variable "alcyon_records_manager_db_cluster_parameter_group_family" {}
variable "alcyon_records_manager_db_snapshot_identifier" {}
variable "alcyon_records_manager_db_instance_count" {}
variable "alcyon_records_manager_db_instance_class" {}


variable "alcyon_pega_deployment_db_engine_version" {}
variable "alcyon_pega_deployment_db_cluster_parameter_group_family" {}
variable "alcyon_pega_deployment_db_snapshot_identifier" {}
variable "alcyon_pega_deployment_db_instance_class" {}
variable "alcyon_pega_deployment_db_instance_count" {}

//core_apps
variable "eks_cluster_admin_ami" {}
variable "eks_cluster_worker_node_ssh_key" {}
variable "jumpbox_security_group_id" {}
variable "eks_version" {}
variable "cluster_worker_node_autoscaling_desired_size" {}
variable "cluster_worker_node_autoscaling_max_size" {}
variable "root_domain" {}
variable "jumpbox_ssh_key" {}

//core_services
variable "pagerduty_integration_key" {}

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
variable "ad_dns" {}
variable "adconnector_subnets" {}

//route53_resolver_rule
variable "description" {}
variable "domain_name" {}
variable "target_ip1" {}


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

//workspaces
variable "default_ou" {}
variable "workspaces_DefaultRole" {}
variable "workspaces_securitygroup_ingress_ports" {}
variable "workspaces_securitygroup_egress_ports" {}
variable "workspaces_ip_group_rule1_source" {}
variable "workspaces_ip_group_rule1_description" {}
variable "workspaces_ip_group_rule2_source" {}
variable "workspaces_ip_group_rule2_description" {}

variable "msk_version" {}
variable "msk_instance_type" {}
variable "msk_ebs_size" {}

variable "es_retention_days" {
  default = 45
}