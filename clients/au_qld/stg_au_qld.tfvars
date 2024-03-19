environment      = "stg"

db_engine_version                 = "11.16"
db_cluster_parameter_group_family = "aurora-postgresql11"
db_instance_class                 = "db.r6g.xlarge"  # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html#Concepts.DBInstanceClass.SupportAurora
db_instance_count                 = 1
db_snapshot_identifier            = "alcyon-pega-855-clean-20220926"

msk_version = "2.6.2"
msk_instance_type = "kafka.t3.small"
msk_ebs_size = "1000"

alcyon_report_db_engine_version                 = "11.13"
alcyon_report_db_cluster_parameter_group_family = "aurora-postgresql11"
alcyon_report_db_instance_class                 = "db.t4g.medium"
alcyon_report_db_instance_count                 = 1
alcyon_report_db_snapshot_identifier            = ""

alcyon_backoffice_migration_elasticache_engine_version      = "5.0.6"
alcyon_backoffice_migration_elasticache_snapshot_identifier = ""
alcyon_backoffice_migration_elasticache_param_group_family  = "redis5.0"
alcyon_backoffice_migration_elasticache_node_type           = "cache.t2.small"
alcyon_backoffice_migration_elasticache_replica_count       = 2
alcyon_backoffice_migration_docdb_engine_version            = "3.6.0"
alcyon_backoffice_migration_docdb_param_group_family        = "docdb3.6"
alcyon_backoffice_migration_docdb_snapshot_identifier       = ""
alcyon_backoffice_migration_docdb_instance_class            = "db.r5.large"
alcyon_backoffice_migration_docdb_instance_count            = 1

alcyon_records_manager_db_engine_version                 = "11.13"
alcyon_records_manager_db_cluster_parameter_group_family = "aurora-postgresql11"
alcyon_records_manager_db_instance_class                 = "db.t4g.medium"
alcyon_records_manager_db_instance_count                 = 1
alcyon_records_manager_db_snapshot_identifier            = ""

//core_services
pagerduty_integration_key                              = "e102c7a8037f4e02c08467651bb43d88" #Test key
security_account_cloudtrail_bucket                     = "au-qld-cloudtrail-s3"

//core_apps
eks_cluster_admin_ami                                  = "ami-0a1a9741b091af3c4"  # 3.1.1.4 Redhat CIS Image https://aws.amazon.com/marketplace/server/configuration?productId=1b60cacb-a6b8-4a58-b152-212ee502fc91&ref_=psb_cfg_continue
eks_cluster_worker_node_ssh_key                        = "stg-au-qld-core-apps-eks-key"
eks_cluster_admin_additional_ingress_security_group_id = "" # To SSH from Jump Box to Admin Box
jumpbox_ssh_key                                        = "stg-au-qld-core-apps-eks-key"
eks_version                                            = 1.26
root_domain                                            = "redflexqld.onl"
cluster_worker_node_autoscaling_desired_size           = 2
cluster_worker_node_autoscaling_max_size               = 3

//domain_controller
domaincontroller_ami                                   = "ami-04a42bffa0ce9dd6e"  # https://aws.amazon.com/marketplace/server/configuration?productId=2388e867-6f4e-45c4-bf4e-78d4c3a870d6&ref_=psb_cfg_continue
instance_type                                          = "t3.large"
domaincontroller_disk_size                             = "100"
domaincontroller_ssh_key                               = "stg-au-qld-dc-ec2-key"
domaincontroller_securitygroup_ingress_ports = []
domaincontroller_securitygroup_egress_ports = []

//adconnector
activedirectoryname = "gtsmgt.com"
adconnector_username = "svc_awsadconnect"
adconnector_password = "SuperSecretPassw0rd"
adconnectorsize = "Small"

//it_service
itservice_ami                                   = "ami-04a42bffa0ce9dd6e"  # https://aws.amazon.com/marketplace/server/configuration?productId=2388e867-6f4e-45c4-bf4e-78d4c3a870d6&ref_=psb_cfg_continue
itservice_instance_type                         = "t3.large"
itservice_disk_size                             = "100"
itservice_ssh_key                               = "stg-au-qld-itsvc-ec2-key"
itservice_securitygroup_ingress_ports = []
itservice_securitygroup_egress_ports = []

//core_network
subnet_short         = "10.138"
vpc_instance_tenancy = "default"
ssm_managed_instance_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

additional_internal_routes = [
//  {
//    carrier_gateway_id         = ""
//    cidr_block                 = "10.135.0.0/16"
//    destination_prefix_list_id = ""
//    egress_only_gateway_id     = ""
//    gateway_id                 = ""
//    instance_id                = ""
//    ipv6_cidr_block            = ""
//    local_gateway_id           = ""
//    nat_gateway_id             = ""
//    network_interface_id       = ""
//    transit_gateway_id         = "tgw-02bdf8ddc6be92890"
//    vpc_endpoint_id            = ""
//    vpc_peering_connection_id  = ""
//  }
]

allowed_ips = [
  "103.87.254.138/32",
  "15.206.230.67/32",
  "5.2.19.94/32",
  "216.161.174.141/32",
  "216.161.174.142/32"
]