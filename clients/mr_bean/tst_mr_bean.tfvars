environment                       = "tst"
db_engine_version                 = "11.13"
db_cluster_parameter_group_family = "aurora-postgresql11"
db_instance_class                 = "db.r6g.xlarge"  # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html#Concepts.DBInstanceClass.SupportAurora
db_instance_count                 = 1
db_snapshot_identifier            = "tst-mr-bean-alcyon-backoffice-20220413"
msk_version = "2.6.2"
msk_instance_type = "kafka.t3.small"
msk_ebs_size = "1000"

alcyon_report_db_engine_version                 = "11.13"
alcyon_report_db_cluster_parameter_group_family = "aurora-postgresql11"
alcyon_report_db_instance_class                 = "db.t4g.medium"
alcyon_report_db_instance_count                 = 1
alcyon_report_db_snapshot_identifier            = "tst-mr-bean-alcyon-backoffice-report-20220413"

alcyon_backoffice_migration_elasticache_engine_version      = "5.0.6"
alcyon_backoffice_migration_elasticache_snapshot_identifier = ""
alcyon_backoffice_migration_elasticache_param_group_family  = "redis5.0"
alcyon_backoffice_migration_elasticache_node_type           = "cache.t2.small"
alcyon_backoffice_migration_elasticache_replica_count       = 2
alcyon_backoffice_migration_docdb_engine_version            = "3.6.0"
alcyon_backoffice_migration_docdb_param_group_family        = "docdb3.6"
alcyon_backoffice_migration_docdb_snapshot_identifier       = "alcyon-mongo-neo-aur-db-cluster-20211208"
alcyon_backoffice_migration_docdb_instance_class            = "db.r5.large"
alcyon_backoffice_migration_docdb_instance_count            = 1

alcyon_field_service_db_engine_version                 = "12.12"
alcyon_field_service_db_cluster_parameter_group_family = "aurora-postgresql12"
alcyon_field_service_db_instance_class                 = "db.r5.large"
alcyon_field_service_db_instance_count                 = 1
alcyon_field_service_db_snapshot_identifier            = "tst-mr-bean-alcyon-field-service-20220413"

alcyon_control_db_engine_version                 = "12.8"
alcyon_control_db_cluster_parameter_group_family = "aurora-postgresql12"
alcyon_control_db_instance_class                 = "db.t4g.medium"
alcyon_control_db_instance_count                 = 1
alcyon_control_db_snapshot_identifier            = "tst-mr-bean-alcyon-control-20220413"

alcyon_records_manager_db_engine_version                 = "11.13"
alcyon_records_manager_db_cluster_parameter_group_family = "aurora-postgresql11"
alcyon_records_manager_db_instance_class                 = "db.t4g.medium"
alcyon_records_manager_db_instance_count                 = 1
alcyon_records_manager_db_snapshot_identifier            = "tst-mr-bean-alcyon-records-manager-20220413"

alcyon_pega_deployment_db_engine_version                 = "11.13"
alcyon_pega_deployment_db_cluster_parameter_group_family = "aurora-postgresql11"
alcyon_pega_deployment_db_instance_class                 = "db.r6g.xlarge"
alcyon_pega_deployment_db_instance_count                 = 1
alcyon_pega_deployment_db_snapshot_identifier            = ""

//core_services
pagerduty_integration_key                              = "e102c7a8037f4e02c08467651bb43d88" #Test key

//core_apps
eks_cluster_admin_ami                                  = "ami-0a1a9741b091af3c4"  # 3.1.1.4 Redhat CIS Image https://aws.amazon.com/marketplace/server/configuration?productId=1b60cacb-a6b8-4a58-b152-212ee502fc91&ref_=psb_cfg_continue
eks_cluster_worker_node_ssh_key                        = "tst-mr-bean-core-apps-eks-key"
jumpbox_security_group_id                              = "sg-0b575ca3eb9495c6e" # To SSH from Jump Box to Admin Box
jumpbox_ssh_key                                        = "tst-mr-bean-core-apps-eks-key"
eks_version                                            = 1.21
root_domain                                            = "rts.onl"
cluster_worker_node_autoscaling_desired_size           = 4
cluster_worker_node_autoscaling_max_size               = 8

//domain_controller
domaincontroller_ami                                   = "ami-04a42bffa0ce9dd6e"  # https://aws.amazon.com/marketplace/server/configuration?productId=2388e867-6f4e-45c4-bf4e-78d4c3a870d6&ref_=psb_cfg_continue
instance_type                                          = "t3.large"
domaincontroller_disk_size                             = "100"
domaincontroller_ssh_key                               = "tst-mr-bean-dc-ec2-key"
domaincontroller_securitygroup_ingress_ports = [
  {
    protocol = "tcp"
    from_port = "3389"
    to_port = "3389"
    cidr_blocks = ["10.254.0.0/16"]
    security_groups = null
    description = "RDP"
  },
  {
    protocol = "tcp"
    from_port = "22"
    to_port = "22"
    cidr_blocks = null
    security_groups = ["sg-07a3f4aca1e0e9ce4"]
    description = "test port 22"
  },
  {
    protocol = "-1"
    from_port = "0"
    to_port = "0"
    cidr_blocks = ["10.254.0.0/16"]
    security_groups = null
    description = "allow all VPC"
  },
  {
    protocol = "-1"
    from_port = "0"
    to_port = "0"
    cidr_blocks = ["10.28.0.0/16"]
    security_groups = null
    description = "allow all VPC"
  }


]
domaincontroller_securitygroup_egress_ports = [
  {
    protocol = "-1"
    from_port = "0"
    to_port = "0"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = null
    description = "allow all"
  }
]

//adconnector
activedirectoryname = "tstmrbean.com"
adconnector_username = "svc_awsadconnect"
adconnector_password = "SuperSecretPassw0rd"
adconnectorsize = "Small"
ad_dns = ["10.254.2.63"]
adconnector_subnets = ["subnet-0c2b219bae878d539", "subnet-0c010cf2422444f61"]

//route53_resolver_rule
description = "tstmrbean"
domain_name = "tstmrbean.com"
target_ip1 =  "10.254.2.63"

//it_service
itservice_ami                                   = "ami-04a42bffa0ce9dd6e"  # https://aws.amazon.com/marketplace/server/configuration?productId=2388e867-6f4e-45c4-bf4e-78d4c3a870d6&ref_=psb_cfg_continue
itservice_instance_type                         = "t3.large"
itservice_disk_size                             = "100"
itservice_ssh_key                               = "tst-mr-bean-itsvc-ec2-key"
itservice_securitygroup_ingress_ports = [
  {
    protocol = "tcp"
    from_port = "3389"
    to_port = "3389"
    cidr_blocks = ["10.254.0.0/16"]
    security_groups = null
    description = "RDP"
  },
  {
    protocol = "tcp"
    from_port = "22"
    to_port = "22"
    cidr_blocks = null
    security_groups = ["sg-07a3f4aca1e0e9ce4"]
    description = "test port 22"
  },
  {
    protocol = "-1"
    from_port = "0"
    to_port = "0"
    cidr_blocks = ["10.254.0.0/16"]
    security_groups = null
    description = "allow all VPC"
  },
  {
    protocol = "-1"
    from_port = "0"
    to_port = "0"
    cidr_blocks = ["10.28.0.0/16"]
    security_groups = null
    description = "Mumbai"
  }
]
itservice_securitygroup_egress_ports = [
  {
    protocol = "-1"
    from_port = "0"
    to_port = "0"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = null
    description = "allow all"
  },
  {
    protocol = "-1"
    from_port = "0"
    to_port = "0"
    cidr_blocks = ["10.254.0.0/16"]
    security_groups = null
    description = "allow icmp"
  }
]


//workspaces
default_ou = "OU=WorkSpaces,OU=mrbean,DC=tstmrbean,DC=com"
workspaces_DefaultRole                  = "tst-mr-bean-workspaces-workspaces_DefaultRole"  //use workspaces_DefaultRole only for first Workspaces environment. use: uat-workspaces_DefaultRole etc. for next workspaces
workspaces_securitygroup_ingress_ports = [
  {
    protocol = "icmp"
    from_port = "-1"
    to_port = "-1"
    cidr_blocks = ["10.254.0.0/16"]
    security_groups = null
    description = "ICMP"
  }
]
workspaces_securitygroup_egress_ports = [
  {
    protocol = "-1"
    from_port = "0"
    to_port = "0"
    cidr_blocks = ["10.254.0.0/16"]
    security_groups = null
    description = "allow all"
  },
  {
    protocol = "-1"
    from_port = "0"
    to_port = "0"
    cidr_blocks = ["10.251.0.0/16"]
    security_groups = null
    description = "STG"
  },
  {
    protocol = "-1"
    from_port = "0"
    to_port = "0"
    cidr_blocks = ["10.35.0.0/16"]
    security_groups = null
    description = "DEVUS-Oregon"
  }
]
workspaces_ip_group_rule1_source = "8.8.8.8/32"
workspaces_ip_group_rule1_description = ""
workspaces_ip_group_rule2_source = "8.8.8.8/32"
workspaces_ip_group_rule2_description = ""


//core_network

subnet_short         = "10.254"
vpc_instance_tenancy = "default"
ssm_managed_instance_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

additional_internal_ingress_ports = [
  {
    rule_no     = 500
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "172.31.0.0/16"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 510
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "10.28.0.0/16"
    from_port   = 0
    to_port     = 0
  }
]

additional_internal_egress_ports = [
  {
    rule_no     = 500
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "172.31.0.0/16"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 510
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "10.28.0.0/16"
    from_port   = 0
    to_port     = 0
  }
]


additional_workspaces_ingress_ports = [
  {
    rule_no     = 500
    protocol    = "tcp"
    rule_action = "allow"
    cidr_block  = "172.19.0.0/16"
    from_port   = 5432
    to_port     = 5432
  },
  {
    rule_no     = 501
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "10.251.0.0/16"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 502
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "10.40.0.0/16"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 503
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "10.33.0.0/16"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 504
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "10.35.0.0/16"
    from_port   = 0
    to_port     = 0
  }
]

additional_workspaces_egress_ports = [
  {
    rule_no     = 500
    protocol    = "tcp"
    rule_action = "allow"
    cidr_block  = "172.19.0.0/16"
    from_port   = 5432
    to_port     = 5432
  },
  {
    rule_no     = 501
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "10.251.0.0/16"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 502
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "10.40.0.0/16"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 503
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "10.33.0.0/16"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 504
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "10.35.0.0/16"
    from_port   = 0
    to_port     = 0
  }
]


additional_internal_routes = [
  {
    carrier_gateway_id         = ""
    cidr_block                 = "172.31.0.0/16"
    destination_prefix_list_id = ""
    egress_only_gateway_id     = ""
    gateway_id                 = "vgw-0eb3982d093c07990"
    instance_id                = ""
    ipv6_cidr_block            = ""
    local_gateway_id           = ""
    nat_gateway_id             = ""
    network_interface_id       = ""
    transit_gateway_id         = ""
    vpc_endpoint_id            = ""
    vpc_peering_connection_id  = ""
  },
  {
    carrier_gateway_id         = ""
    cidr_block                 = "10.28.0.0/16"
    destination_prefix_list_id = ""
    egress_only_gateway_id     = ""
    gateway_id                 = ""
    instance_id                = ""
    ipv6_cidr_block            = ""
    local_gateway_id           = ""
    nat_gateway_id             = ""
    network_interface_id       = ""
    transit_gateway_id         = ""
    vpc_endpoint_id            = ""
    vpc_peering_connection_id  = "pcx-05ddc9eca87002c70"
  },
  {
    carrier_gateway_id         = ""
    cidr_block                 = "10.0.0.0/24"
    destination_prefix_list_id = ""
    egress_only_gateway_id     = ""
    gateway_id                 = ""
    instance_id                = ""
    ipv6_cidr_block            = ""
    local_gateway_id           = ""
    nat_gateway_id             = ""
    network_interface_id       = ""
    transit_gateway_id         = ""
    vpc_endpoint_id            = ""
    vpc_peering_connection_id  = "pcx-0449d760f7853b425"
  }
]
additional_workspaces_routes = [
  {
    carrier_gateway_id         = ""
    cidr_block                 = "10.251.0.0/16"
    destination_prefix_list_id = ""
    egress_only_gateway_id     = ""
    gateway_id                 = ""
    instance_id                = ""
    ipv6_cidr_block            = ""
    local_gateway_id           = ""
    nat_gateway_id             = ""
    network_interface_id       = ""
    transit_gateway_id         = ""
    vpc_endpoint_id            = ""
    vpc_peering_connection_id  = "pcx-025b45a75d1ff8938"
  },
  {
    carrier_gateway_id         = ""
    cidr_block                 = "10.35.0.0/16"
    destination_prefix_list_id = ""
    egress_only_gateway_id     = ""
    gateway_id                 = ""
    instance_id                = ""
    ipv6_cidr_block            = ""
    local_gateway_id           = ""
    nat_gateway_id             = ""
    network_interface_id       = ""
    transit_gateway_id         = ""
    vpc_endpoint_id            = ""
    vpc_peering_connection_id  = "pcx-0ac1537b0c1d719ec"
  },
  {
    carrier_gateway_id         = ""
    cidr_block                 = "10.40.0.0/16"
    destination_prefix_list_id = ""
    egress_only_gateway_id     = ""
    gateway_id                 = ""
    instance_id                = ""
    ipv6_cidr_block            = ""
    local_gateway_id           = ""
    nat_gateway_id             = ""
    network_interface_id       = ""
    transit_gateway_id         = ""
    vpc_endpoint_id            = ""
    vpc_peering_connection_id  = "pcx-0fd7ebc74dba5dfa2"
  },
  {
    carrier_gateway_id         = ""
    cidr_block                 = "0.0.0.0/0"
    destination_prefix_list_id = ""
    egress_only_gateway_id     = ""
    gateway_id                 = ""
    instance_id                = ""
    ipv6_cidr_block            = ""
    local_gateway_id           = ""
    nat_gateway_id             = "nat-07b19e0e8cabaa63d"
    network_interface_id       = ""
    transit_gateway_id         = ""
    vpc_endpoint_id            = ""
    vpc_peering_connection_id  = ""
  },
  {
    carrier_gateway_id         = ""
    cidr_block                 = "10.33.0.0/16"
    destination_prefix_list_id = ""
    egress_only_gateway_id     = ""
    gateway_id                 = ""
    instance_id                = ""
    ipv6_cidr_block            = ""
    local_gateway_id           = ""
    nat_gateway_id             = ""
    network_interface_id       = ""
    transit_gateway_id         = ""
    vpc_endpoint_id            = ""
    vpc_peering_connection_id  = "pcx-0610f60cfdb03309a"
  },
  {
    carrier_gateway_id         = ""
    cidr_block                 = "10.0.0.0/24"
    destination_prefix_list_id = ""
    egress_only_gateway_id     = ""
    gateway_id                 = ""
    instance_id                = ""
    ipv6_cidr_block            = ""
    local_gateway_id           = ""
    nat_gateway_id             = ""
    network_interface_id       = ""
    transit_gateway_id         = ""
    vpc_endpoint_id            = ""
    vpc_peering_connection_id  = "pcx-0449d760f7853b425"
  }
]

additional_approach_routes = [
  {
    carrier_gateway_id         = ""
    cidr_block                 = "10.0.0.0/24"
    destination_prefix_list_id = ""
    egress_only_gateway_id     = ""
    gateway_id                 = ""
    instance_id                = ""
    ipv6_cidr_block            = ""
    local_gateway_id           = ""
    nat_gateway_id             = ""
    network_interface_id       = ""
    transit_gateway_id         = ""
    vpc_endpoint_id            = ""
    vpc_peering_connection_id  = "pcx-0449d760f7853b425"
  }
]

additional_dmz_routes = [
  {
    carrier_gateway_id         = ""
    cidr_block                 = "10.0.0.0/24"
    destination_prefix_list_id = ""
    egress_only_gateway_id     = ""
    gateway_id                 = ""
    instance_id                = ""
    ipv6_cidr_block            = ""
    local_gateway_id           = ""
    nat_gateway_id             = ""
    network_interface_id       = ""
    transit_gateway_id         = ""
    vpc_endpoint_id            = ""
    vpc_peering_connection_id  = "pcx-0449d760f7853b425"
  }
]

additional_secure_routes = [
  {
    carrier_gateway_id         = ""
    cidr_block                 = "10.0.0.0/24"
    destination_prefix_list_id = ""
    egress_only_gateway_id     = ""
    gateway_id                 = ""
    instance_id                = ""
    ipv6_cidr_block            = ""
    local_gateway_id           = ""
    nat_gateway_id             = ""
    network_interface_id       = ""
    transit_gateway_id         = ""
    vpc_endpoint_id            = ""
    vpc_peering_connection_id  = "pcx-0449d760f7853b425"
  }
]