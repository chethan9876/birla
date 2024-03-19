environment                       = "prd"
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
alcyon_backoffice_migration_docdb_param_group_tls_enabled   = "enabled"
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
security_account_cloudtrail_bucket                     = "redflexsec-cloudtrail-logs"

//core_apps
eks_cluster_admin_ami                                  = "ami-0a1a9741b091af3c4"  # 3.1.1.4 Redhat CIS Image https://aws.amazon.com/marketplace/server/configuration?productId=1b60cacb-a6b8-4a58-b152-212ee502fc91&ref_=psb_cfg_continue
eks_cluster_worker_node_ssh_key                        = "prd-au-nt-core-apps-eks-key"
eks_cluster_admin_additional_ingress_security_group_id = "" # To SSH from Jump Box to Admin Box
jumpbox_ssh_key                                        = "prd-au-nt-core-apps-eks-key"
eks_version                                            = 1.24
root_domain                                            = "redflexnt.onl"
cluster_worker_node_autoscaling_min_size               = 3
cluster_worker_node_autoscaling_desired_size           = 3
cluster_worker_node_autoscaling_max_size               = 4

//domain_controller
domaincontroller_ami                                   = "ami-04a42bffa0ce9dd6e"  # https://aws.amazon.com/marketplace/server/configuration?productId=2388e867-6f4e-45c4-bf4e-78d4c3a870d6&ref_=psb_cfg_continue
instance_type                                          = "t3.large"
domaincontroller_disk_size                             = "100"
domaincontroller_ssh_key                               = "prd-au-nt-dc-ec2-key"
domaincontroller_securitygroup_ingress_ports = [
  {
    protocol = "tcp"
    from_port = "3389"
    to_port = "3389"
    cidr_blocks = ["192.168.96.0/20"]
    security_groups = null
    description = "RDP"
  },
  {
    protocol = "tcp"
    from_port = "3389"
    to_port = "3389"
    cidr_blocks = ["192.168.96.0/20"]
    security_groups = null
    description = "RDP"
  },
  {
    protocol = "-1"
    from_port = "0"
    to_port = "0"
    cidr_blocks = ["192.168.217.0/24"]
    security_groups = null
    description = "allow all VPC"
  },
  {
    protocol = "-1"
    from_port = "0"
    to_port = "0"
    cidr_blocks = ["192.168.217.0/24"]
    security_groups = null
    description = "allow all VPC"
  },
  {
    protocol = "-1"
    from_port = "0"
    to_port = "0"
    cidr_blocks = ["10.135.0.0/16"]
    security_groups = null
    description = "allow all 10.135"
  },
  {
    protocol = "icmp"
    from_port = "-1"
    to_port = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = null
    description = "allow ping"
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
activedirectoryname = "prdredflexnt.com"
adconnector_username = "svc_awsadconnect"
adconnector_password = "SuperSecretPassw0rd"
adconnectorsize = "Small"

//it_service
itservice_ami                                   = "ami-04a42bffa0ce9dd6e"  # https://aws.amazon.com/marketplace/server/configuration?productId=2388e867-6f4e-45c4-bf4e-78d4c3a870d6&ref_=psb_cfg_continue
itservice_instance_type                         = "t3.large"
itservice_disk_size                             = "100"
itservice_ssh_key                               = "prd-au-nt-itsvc-ec2-key"
itservice_securitygroup_ingress_ports = [
  {
    protocol = "tcp"
    from_port = "3389"
    to_port = "3389"
    cidr_blocks = ["192.168.96.0/20"]
    security_groups = null
    description = "RDP"
  },
  {
    protocol = "tcp"
    from_port = "3389"
    to_port = "3389"
    cidr_blocks = ["192.168.217.0/24"]
    security_groups = null
    description = "RDP"
  },
  {
    protocol = "-1"
    from_port = "0"
    to_port = "0"
    cidr_blocks = ["192.168.96.0/20"]
    security_groups = null
    description = "allow all VPC"
  },
  {
    protocol = "-1"
    from_port = "0"
    to_port = "0"
    cidr_blocks = ["192.168.217.0/24"]
    security_groups = null
    description = "allow all VPC"
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
  }
]

//core_network vpc = 192..168.112.0/20 and 192..168.216.0/24
subnet_short         = ""
vpc_cidr             = "192.168.96.0/20"
additional_vpc_cidr  = "192.168.217.0/24"
vpc_instance_tenancy = "default"
ssm_managed_instance_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
allowed_ips = [
  "103.87.254.138/32",
  "15.206.230.67/32",
  "5.2.19.94/32",
  "216.161.174.141/32",
  "216.161.174.142/32",
  "192.168.96.0/20",
  "192.168.217.0/24"
]

//subnets
subnets_dmz = {
  "ap-southeast-2a" = "192.168.101.0/24",
  "ap-southeast-2b" = "192.168.102.0/24"
}
subnets_internal = {
  "ap-southeast-2a" = "192.168.217.0/26",
  "ap-southeast-2b" = "192.168.217.64/26",
  "ap-southeast-2c" = "192.168.217.128/26"
}
subnets_database = {
  "ap-southeast-2a" = "192.168.96.0/24",
  "ap-southeast-2b" = "192.168.97.0/24",
  "ap-southeast-2c" = "192.168.98.0/24"
}
subnets_approach = {
  "ap-southeast-2a" = "192.168.105.0/24"
}
subnets_secure = {
  "ap-southeast-2a" = "192.168.106.0/24"
}
subnets_workspaces = {
  "ap-southeast-2a" = "192.168.108.0/24",
  "ap-southeast-2b" = "192.168.109.0/24"
}

//routes
dmz_routes = [
  {
    cidr_block                 = "0.0.0.0/0"
    destination_prefix_list_id = null
    ipv6_cidr_block            = null
    carrier_gateway_id         = null
    egress_only_gateway_id     = null
    gateway_id                 = null
    instance_id                = null
    nat_gateway_id             = null
    local_gateway_id           = null
    network_interface_id       = null
    transit_gateway_id         = null
    vpc_endpoint_id            = null
    vpc_peering_connection_id  = null
  }
]

internal_routes = [
  {
    cidr_block                 = null
    destination_prefix_list_id = "pl-0c11be76c2644d111"
    ipv6_cidr_block            = null
    carrier_gateway_id         = null
    egress_only_gateway_id     = null
    gateway_id                 = null
    instance_id                = null
    nat_gateway_id             = null
    local_gateway_id           = null
    network_interface_id       = null
    transit_gateway_id         = "tgw-02853e3abfd4510d0"
    vpc_endpoint_id            = null
    vpc_peering_connection_id  = null
  },
  {
    cidr_block                 = "0.0.0.0/0"
    destination_prefix_list_id = null
    ipv6_cidr_block            = null
    carrier_gateway_id         = null
    egress_only_gateway_id     = null
    gateway_id                 = null
    instance_id                = null
    nat_gateway_id             = null
    local_gateway_id           = null
    network_interface_id       = null
    transit_gateway_id         = null
    vpc_endpoint_id            = null
    vpc_peering_connection_id  = null
  }
]

approach_routes  = [
  {
    cidr_block                 = "0.0.0.0/0"
    destination_prefix_list_id = null
    ipv6_cidr_block            = null
    carrier_gateway_id         = null
    egress_only_gateway_id     = null
    gateway_id                 = null
    instance_id                = null
    nat_gateway_id             = null
    local_gateway_id           = null
    network_interface_id       = null
    transit_gateway_id         = null
    vpc_endpoint_id            = null
    vpc_peering_connection_id  = null
  }
]

secure_routes = [
  {
    cidr_block                 = "0.0.0.0/0"
    destination_prefix_list_id = null
    ipv6_cidr_block            = null
    carrier_gateway_id         = null
    egress_only_gateway_id     = null
    gateway_id                 = null
    instance_id                = null
    nat_gateway_id             = null
    local_gateway_id           = null
    network_interface_id       = null
    transit_gateway_id         = null
    vpc_endpoint_id            = null
    vpc_peering_connection_id  = null
  }
]

//ingress rules
dmz_ingress_ports = [
  {
    rule_no = 100
    protocol = "6"
    rule_action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  },
  {
    rule_no = 110
    protocol = "6"
    rule_action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 443
    to_port = 443
  },
  {
    rule_no = 120
    protocol = "6"
    rule_action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 22
    to_port = 22
  },
  {
    rule_no = 130
    protocol = "6"
    rule_action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  },
  {
    rule_no = 131
    protocol = "17"
    rule_action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  },
  {
    rule_no = 140
    protocol = "6"
    rule_action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 53
    to_port = 53
  },
  {
    rule_no = 141
    protocol = "17"
    rule_action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 53
    to_port = 53
  },
  {
    rule_no = 150
    protocol = "6"
    rule_action = "allow"
    cidr_block = "192.168.217.0/24"
    from_port = 389
    to_port = 389
  },
  {
    rule_no = 151
    protocol = "17"
    rule_action = "allow"
    cidr_block = "192.168.217.0/24"
    from_port = 389
    to_port = 389
  },
  {
    rule_no = 152
    protocol = "6"
    rule_action = "allow"
    cidr_block = "192.168.217.0/24"
    from_port = 88
    to_port = 88
  },
  {
    rule_no = 153
    protocol = "6"
    rule_action = "allow"
    cidr_block = "192.168.217.0/24"
    from_port = 445
    to_port = 445
  },
  {
    rule_no = 154
    protocol = "6"
    rule_action = "allow"
    cidr_block = "192.168.217.0/24"
    from_port = 464
    to_port = 464
  }
]
internal_ingress_ports = [
  {
    rule_no     = 90
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "192.168.96.0/20"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 95
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 100
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 80
    to_port     = 80
  },
  {
    rule_no     = 110
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 443
    to_port     = 443
  },
  {
    rule_no     = 120
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 22
    to_port     = 22
  },
  {
    rule_no     = 130
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 131
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 140
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  },
  {
    rule_no     = 141
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  },
  {
    rule_no     = 190
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 389
    to_port     = 389
  },
  {
    rule_no     = 191
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 389
    to_port     = 389
  },
  {
    rule_no     = 200
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 88
    to_port     = 88
  },
  {
    rule_no     = 128
    protocol    = "6"
    rule_action = "deny"
    cidr_block  = "192.168.108.0/23"
    from_port   = 22
    to_port     = 22
  },
  {
    rule_no     = 91
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "10.135.0.0/16"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 92
    protocol    = "1"
    rule_action = "allow"
    cidr_block  = "10.135.0.0/16"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 400
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "172.21.130.144/28"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 410
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "172.20.23.0/24"
    from_port   = 0
    to_port     = 0
  }
]
database_ingress_ports = [
  {
    rule_no     = 100
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 80
    to_port     = 80
  },
  {
    rule_no     = 110
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 443
    to_port     = 443
  },
  {
    rule_no     = 150
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.96.0/20"
    from_port   = 5432
    to_port     = 5432
  },
  {
    rule_no     = 155
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 5432
    to_port     = 5432
  },
  {
    rule_no     = 160
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.96.0/20"
    from_port   = 6379
    to_port     = 6379
  },
  {
    rule_no     = 165
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 6379
    to_port     = 6379
  },
  {
    rule_no     = 170
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.96.0/20"
    from_port   = 27017
    to_port     = 27017
  },
  {
    rule_no     = 175
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 27017
    to_port     = 27017
  },
  {
    rule_no     = 180
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.96.0/20"
    from_port   = 9096
    to_port     = 9096
  },
  {
    rule_no     = 185
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 9096
    to_port     = 9096
  }
]
approach_ingress_ports = [
  {
    rule_no     = 100
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 80
    to_port     = 80
  },
  {
    rule_no     = 110
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 443
    to_port     = 443
  },
  {
    rule_no     = 120
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 22
    to_port     = 22
  },
  {
    rule_no     = 130
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 131
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 140
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  },
  {
    rule_no     = 141
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  }
]
secure_ingress_ports = [
  {
    rule_no     = 100
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 80
    to_port     = 80
  },
  {
    rule_no     = 110
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 443
    to_port     = 443
  },
  {
    rule_no     = 120
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 22
    to_port     = 22
  },
  {
    rule_no     = 130
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 131
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 140
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  },
  {
    rule_no     = 141
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  },
  {
    rule_no     = 160
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 0
    to_port     = 65535
  }
]
workspaces_ingress_ports = [
  {
    rule_no     = 90
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "192.168.96.0/20"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 95
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 100
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 80
    to_port     = 80
  },
  {
    rule_no     = 110
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 443
    to_port     = 443
  },
  {
    rule_no     = 120
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 22
    to_port     = 22
  },
  {
    rule_no     = 130
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 131
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 140
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  },
  {
    rule_no     = 141
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  }
]

//egress rules
dmz_egress_ports = [
  {
    rule_no     = 100
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 80
    to_port     = 80
  },
  {
    rule_no     = 110
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 443
    to_port     = 443
  },
  {
    rule_no     = 120
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 22
    to_port     = 22
  },
  {
    rule_no     = 130
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 131
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 140
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  },
  {
    rule_no     = 141
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  },
  {
    rule_no     = 150
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 389
    to_port     = 389
  },
  {
    rule_no     = 151
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 389
    to_port     = 389
  },
  {
    rule_no     = 152
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 88
    to_port     = 88
  },
  {
    rule_no     = 153
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 445
    to_port     = 445
  },
  {
    rule_no     = 154
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 464
    to_port     = 464
  }
]
internal_egress_ports = [
  {
    rule_no     = 90
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "192.168.96.0/20"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 95
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 100
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 80
    to_port     = 80
  },
  {
    rule_no     = 110
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 443
    to_port     = 443
  },
  {
    rule_no     = 120
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 22
    to_port     = 22
  },
  {
    rule_no     = 130
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 131
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 140
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  },
  {
    rule_no     = 141
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  },
  {
    rule_no     = 150
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 5432
    to_port     = 5432
  },
  {
    rule_no     = 190
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 389
    to_port     = 389
  },
  {
    rule_no     = 191
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 389
    to_port     = 389
  },
  {
    rule_no     = 200
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 88
    to_port     = 88
  },
  {
    rule_no     = 128
    protocol    = "6"
    rule_action = "deny"
    cidr_block  = "192.168.108.0/23"
    from_port   = 22
    to_port     = 22
  },
  {
    rule_no     = 91
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "10.135.0.0/16"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 92
    protocol    = "1"
    rule_action = "allow"
    cidr_block  = "10.135.0.0/16"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 400
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/16"
    from_port   = 445
    to_port     = 445
  },
  {
    rule_no     = 500
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "10.2.37.156/32"
    from_port   = 1521
    to_port     = 1521
  }
]
database_egress_ports = [
  {
    rule_no     = 100
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 80
    to_port     = 80
  },
  {
    rule_no     = 110
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 443
    to_port     = 443
  },
  {
    rule_no     = 130
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.96.0/20"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 135
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 1024
    to_port     = 65535
  }
]
approach_egress_ports = [
  {
    rule_no     = 100
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 80
    to_port     = 80
  },
  {
    rule_no     = 110
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 443
    to_port     = 443
  },
  {
    rule_no     = 120
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 22
    to_port     = 22
  },
  {
    rule_no     = 130
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 131
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 140
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  },
  {
    rule_no     = 141
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  },
  {
    rule_no     = 150
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.96.0/20"
    from_port   = 5432
    to_port     = 5432
  },
  {
    rule_no     = 155
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 5432
    to_port     = 5432
  }
]
secure_egress_ports = [
  {
    rule_no     = 100
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 80
    to_port     = 80
  },
  {
    rule_no     = 110
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 443
    to_port     = 443
  },
  {
    rule_no     = 120
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 22
    to_port     = 22
  },
  {
    rule_no     = 130
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 131
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 140
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  },
  {
    rule_no     = 141
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  },
  {
    rule_no     = 150
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.96.0/20"
    from_port   = 5432
    to_port     = 5432
  },
  {
    rule_no     = 155
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 5432
    to_port     = 5432
  },
  {
    rule_no     = 160
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 0
    to_port     = 65535
  }
]
workspaces_egress_ports = [
  {
    rule_no     = 90
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "192.168.96.0/20"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 95
    protocol    = "-1"
    rule_action = "allow"
    cidr_block  = "192.168.217.0/24"
    from_port   = 0
    to_port     = 0
  },
  {
    rule_no     = 100
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 80
    to_port     = 80
  },
  {
    rule_no     = 110
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 443
    to_port     = 443
  },
  {
    rule_no     = 120
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 22
    to_port     = 22
  },
  {
    rule_no     = 130
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 131
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024
    to_port     = 65535
  },
  {
    rule_no     = 140
    protocol    = "6"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  },
  {
    rule_no     = 141
    protocol    = "17"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 53
    to_port     = 53
  }
]
