environment = "stg"

db_engine_version                 = "11.16"
db_cluster_parameter_group_family = "aurora-postgresql11"
db_instance_class                 = "db.r6g.xlarge" # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html#Concepts.DBInstanceClass.SupportAurora
db_instance_count                 = 1
db_snapshot_identifier            = "alcyon-pega-855-clean-20220926"

msk_version       = "2.6.2"
msk_instance_type = "kafka.t3.small"
msk_ebs_size      = "1000"

alcyon_report_db_engine_version                 = "11.13"
alcyon_report_db_cluster_parameter_group_family = "aurora-postgresql11"
alcyon_report_db_instance_class                 = "db.t4g.medium"
alcyon_report_db_instance_count                 = 1
alcyon_report_db_snapshot_identifier            = ""

alcyon_records_manager_db_engine_version                 = "11.13"
alcyon_records_manager_db_cluster_parameter_group_family = "aurora-postgresql11"
alcyon_records_manager_db_instance_class                 = "db.t4g.medium"
alcyon_records_manager_db_instance_count                 = 1
alcyon_records_manager_db_snapshot_identifier            = ""

alcyon_control_db_engine_version                 = "12.8"
alcyon_control_db_cluster_parameter_group_family = "aurora-postgresql12"
alcyon_control_db_instance_class                 = "db.t4g.medium"
alcyon_control_db_instance_count                 = 2
alcyon_control_db_snapshot_identifier            = ""

alcyon_express_db_engine_version                 = "12.8"
alcyon_express_db_cluster_parameter_group_family = "aurora-postgresql12"
alcyon_express_db_instance_class                 = "db.t4g.medium"
alcyon_express_db_instance_count                 = 1
alcyon_express_db_snapshot_identifier            = ""

//core_services
pagerduty_integration_key          = "e102c7a8037f4e02c08467651bb43d88" #Test key
security_account_cloudtrail_bucket = "nz-wk-cloudtrail-s3"

//core_apps
eks_cluster_admin_ami                                  = "ami-0a1a9741b091af3c4" # 3.1.1.4 Redhat CIS Image https://aws.amazon.com/marketplace/server/configuration?productId=1b60cacb-a6b8-4a58-b152-212ee502fc91&ref_=psb_cfg_continue
eks_cluster_worker_node_ssh_key                        = "stg-nz-wk-core-apps-eks-key"
eks_cluster_admin_additional_ingress_security_group_id = "" # To SSH from Jump Box to Admin Box
jumpbox_ssh_key                                        = "stg-nz-wk-core-apps-eks-key"
eks_version                                            = 1.23
root_domain                                            = "redflexnz.onl"
cluster_worker_node_autoscaling_desired_size           = 3
cluster_worker_node_autoscaling_max_size               = 4


//core_network
subnet_short             = "10.137"
vpc_instance_tenancy     = "default"
ssm_managed_instance_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"


//domain_controller
domaincontroller_ami       = "ami-09ed0efda528c1627" # https://aws.amazon.com/marketplace/server/configuration?productId=2388e867-6f4e-45c4-bf4e-78d4c3a870d6&ref_=psb_cfg_continue
instance_type              = "t3.large"
domaincontroller_disk_size = "100"
domaincontroller_ssh_key   = "stg-nz-wk-dc-ec2-key"
domaincontroller_securitygroup_ingress_ports = [
  {
    protocol        = "tcp"
    from_port       = "3389"
    to_port         = "3389"
    cidr_blocks     = ["10.137.0.0/16"]
    security_groups = null
    description     = "RDP"
  },
  {
    protocol        = "-1"
    from_port       = "0"
    to_port         = "0"
    cidr_blocks     = ["10.137.0.0/16"]
    security_groups = null
    description     = "allow all VPC"
  },
  {
    protocol        = "-1"
    from_port       = "0"
    to_port         = "0"
    cidr_blocks     = ["10.137.250.0/24"]
    security_groups = null
    description     = "allow all VPC"
  }


]
domaincontroller_securitygroup_egress_ports = [
  {
    protocol        = "-1"
    from_port       = "0"
    to_port         = "0"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = null
    description     = "allow all"
  }
]

//adconnector
activedirectoryname  = "gtsmgt.com"
adconnector_username = "SVC_DomainJoin"
adconnector_password = "NSWrfx44#"
adconnectorsize      = "Small"

//it_service
itservice_ami           = "ami-09ed0efda528c1627" # https://aws.amazon.com/marketplace/server/configuration?productId=2388e867-6f4e-45c4-bf4e-78d4c3a870d6&ref_=psb_cfg_continue
itservice_instance_type = "t3.large"
itservice_disk_size     = "100"
itservice_ssh_key       = "stg-nz-wk-itsvc-ec2-key"
itservice_securitygroup_ingress_ports = [
  {
    protocol        = "tcp"
    from_port       = "3389"
    to_port         = "3389"
    cidr_blocks     = ["10.137.0.0/16"]
    security_groups = null
    description     = "RDP"
  },
  {
    protocol        = "-1"
    from_port       = "0"
    to_port         = "0"
    cidr_blocks     = ["10.137.0.0/16"]
    security_groups = null
    description     = "allow all VPC"
  }
]
itservice_securitygroup_egress_ports = [
  {
    protocol        = "-1"
    from_port       = "0"
    to_port         = "0"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = null
    description     = "allow all"
  }
]

allowed_ips = [
  "103.87.254.138/32",
  "15.206.230.67/32",
  "5.2.19.94/32",
  "216.161.174.141/32",
  "216.161.174.142/32",
]