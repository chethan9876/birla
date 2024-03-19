environment      = "prd"
dotApiExternalID = "H03tPbOFT?Xva(SFx%PA"

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
security_account_cloudtrail_bucket                     = "au-wa-cloudtrail-s3"

//core_apps
eks_cluster_admin_ami                                  = "ami-0a1a9741b091af3c4"  # 3.1.1.4 Redhat CIS Image https://aws.amazon.com/marketplace/server/configuration?productId=1b60cacb-a6b8-4a58-b152-212ee502fc91&ref_=psb_cfg_continue
eks_cluster_worker_node_ssh_key                        = "prd-au-wa-core-apps-eks-key"
eks_cluster_admin_additional_ingress_security_group_id = "" # To SSH from Jump Box to Admin Box
jumpbox_ssh_key                                        = "prd-au-wa-core-apps-eks-key"
eks_version                                            = 1.22
root_domain                                            = "redflexwa.onl"
cluster_worker_node_autoscaling_desired_size           = 2
cluster_worker_node_autoscaling_max_size               = 3


//core_network
subnet_short         = "10.54"
vpc_instance_tenancy = "default"
ssm_managed_instance_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"