variable "environment" {}
variable "pega_layer" {
  default = "NT"
}


variable "allowed_ips" {}

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
variable "alcyon_backoffice_migration_docdb_param_group_tls_enabled" {
  default = "disabled"
}
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
variable "cluster_worker_node_autoscaling_min_size" {}
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



#core_network
variable "subnet_short" {}
variable "vpc_cidr" {}
variable "additional_vpc_cidr" {}
variable "vpc_instance_tenancy" {}
variable "ssm_managed_instance_arn" {}

//subnets
variable "subnets_dmz" {}
variable "subnets_internal" {}
variable "subnets_database" {}
variable "subnets_approach" {}
variable "subnets_secure" {}
variable "subnets_workspaces" {}

//routes
variable "dmz_routes" {}
variable "internal_routes" {}
variable "approach_routes" {}
variable "secure_routes" {}

//ingress rules
variable "dmz_ingress_ports" {}
variable "internal_ingress_ports" {}
variable "database_ingress_ports" {}
variable "approach_ingress_ports" {}
variable "secure_ingress_ports" {}
variable "workspaces_ingress_ports" {}

//egress rules
variable "dmz_egress_ports" {}
variable "internal_egress_ports" {}
variable "database_egress_ports" {}
variable "approach_egress_ports" {}
variable "secure_egress_ports" {}
variable "workspaces_egress_ports" {}

variable "additional_user_data_admin_box" {
  default = <<-EOT
sudo yum install -y samba
cat <<'EOF' >> /etc/samba/smb.conf
# See smb.conf.example for a more detailed config file or
# read the smb.conf manpage.
# Run 'testparm' to verify the config is correct after
# you modified it.
#
# Note:
# SMB1 is disabled by default. This means clients without support for SMB2 or
# SMB3 are no longer able to connect to smbd (by default).

[global]
workgroup = workgroup
log file = /var/log/samba/log.%m
max log size = 50
dns proxy = no
security = user
min protocol = SMB3
guest account = root

[ingestr]
comment = ingestr share
path = /data/ingestr/
directory mask = 0777
browsable = yes
writable = yes
guest ok = yes
read only = no
create mask = 0777
public = yes
valid users = ingestr
EOF

firewall-cmd --permanent --add-port=445/tcp
firewall-cmd --permanent --add-service=samba
firewall-cmd --reload
setsebool -P samba_enable_home_dirs on
setsebool -P samba_export_all_ro on
setsebool -P samba_export_all_rw on
restorecon /data/ingestr
useradd ingestr
systemctl enable smb
systemctl start smb
EOT
}
