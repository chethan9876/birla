variable "region" {}
variable "environment" {}
variable "client" {}
variable "vpc_instance_tenancy" {}
variable "subnet_short" {}
variable "vpc_cidr" {
  type = string
  default = ""
}
variable "additional_vpc_cidr" {
  type = string
  default = ""
}

variable "subnets_dmz"  {
  type = map(string)
  description = "The DMZ subnets which is a map of availability zones to CIDR blocks"

  default = {
    "region-a" = "subnet.101.0/24",
    "region-b" = "subnet.102.0/24"
  }
}
variable "subnets_internal" {
  type = map(string)
  description = "The internal subnets which is a map of availability zones to CIDR blocks"
  default = {
    "region-a" = "subnet.1.0/24",
    "region-b" = "subnet.2.0/24",
    "region-c" = "subnet.3.0/24"
  }
}
variable "subnets_database" {
  type = map(string)
  description = "The database subnets which is a map of availability zones to CIDR blocks"
  default = {
    "region-a" = "subnet.11.0/24",
    "region-b" = "subnet.12.0/24",
    "region-c" = "subnet.13.0/24"
  }
}
variable "subnets_approach"  {
  type = map(string)
  description = "The approach subnets which is a map of availability zones to CIDR blocks"
  default = {
    "region-a" = "subnet.111.0/24"
  }
}
variable "subnets_secure"  {
  type = map(string)
  description = "The secure subnets which is a map of availability zones to CIDR blocks"
  default = {
    "region-a" = "subnet.112.0/24"
  }
}
variable "subnets_workspaces" {
  type = map(string)
  description = "The workspaces subnets which is a map of availability zones to CIDR blocks"
  default = {
    "region-a" = "subnet.61.0/24",
    "region-b" = "subnet.62.0/24"
  }
}

variable "ssm_managed_instance_arn" {}
variable "profile" {}

variable "dmz_routes" {
  type = list(object({
    cidr_block                 = string
    destination_prefix_list_id = string
    ipv6_cidr_block            = string
    carrier_gateway_id         = string
    egress_only_gateway_id     = string
    gateway_id                 = string
    instance_id                = string
    nat_gateway_id             = string
    local_gateway_id           = string
    network_interface_id       = string
    transit_gateway_id         = string
    vpc_endpoint_id            = string
    vpc_peering_connection_id  = string
  }))
  default = [
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
}

variable "internal_routes" {
  type = list(object({
    cidr_block                 = string
    destination_prefix_list_id = string
    ipv6_cidr_block            = string
    carrier_gateway_id         = string
    egress_only_gateway_id     = string
    gateway_id                 = string
    instance_id                = string
    nat_gateway_id             = string
    local_gateway_id           = string
    network_interface_id       = string
    transit_gateway_id         = string
    vpc_endpoint_id            = string
    vpc_peering_connection_id  = string
  }))
  default = [
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
}
variable "database_routes" {
  type = list(object({
    cidr_block                 = string
    destination_prefix_list_id = string
    ipv6_cidr_block            = string
    carrier_gateway_id         = string
    egress_only_gateway_id     = string
    gateway_id                 = string
    instance_id                = string
    nat_gateway_id             = string
    local_gateway_id           = string
    network_interface_id       = string
    transit_gateway_id         = string
    vpc_endpoint_id            = string
    vpc_peering_connection_id  = string
  }))
  default = []
}
variable "approach_routes" {
  type = list(object({
    cidr_block                 = string
    destination_prefix_list_id = string
    ipv6_cidr_block            = string
    carrier_gateway_id         = string
    egress_only_gateway_id     = string
    gateway_id                 = string
    instance_id                = string
    nat_gateway_id             = string
    local_gateway_id           = string
    network_interface_id       = string
    transit_gateway_id         = string
    vpc_endpoint_id            = string
    vpc_peering_connection_id  = string
  }))
  default = [
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
}
variable "secure_routes" {
  type = list(object({
    cidr_block                 = string
    destination_prefix_list_id = string
    ipv6_cidr_block            = string
    carrier_gateway_id         = string
    egress_only_gateway_id     = string
    gateway_id                 = string
    instance_id                = string
    nat_gateway_id             = string
    local_gateway_id           = string
    network_interface_id       = string
    transit_gateway_id         = string
    vpc_endpoint_id            = string
    vpc_peering_connection_id  = string
  }))
  default = [
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
}
variable "workspaces_routes" {
  type = list(object({
    cidr_block                 = string
    destination_prefix_list_id = string
    ipv6_cidr_block            = string
    carrier_gateway_id         = string
    egress_only_gateway_id     = string
    gateway_id                 = string
    instance_id                = string
    nat_gateway_id             = string
    local_gateway_id           = string
    network_interface_id       = string
    transit_gateway_id         = string
    vpc_endpoint_id            = string
    vpc_peering_connection_id  = string
  }))
  default = []
}


variable "additional_dmz_routes" {
  type = list(object({
    cidr_block                 = string
    destination_prefix_list_id = string
    ipv6_cidr_block            = string
    carrier_gateway_id         = string
    egress_only_gateway_id     = string
    gateway_id                 = string
    instance_id                = string
    nat_gateway_id             = string
    local_gateway_id           = string
    network_interface_id       = string
    transit_gateway_id         = string
    vpc_endpoint_id            = string
    vpc_peering_connection_id  = string
  }))
  default = []
}
variable "additional_internal_routes" {
  type = list(object({
    cidr_block                 = string
    destination_prefix_list_id = string
    ipv6_cidr_block            = string
    carrier_gateway_id         = string
    egress_only_gateway_id     = string
    gateway_id                 = string
    instance_id                = string
    nat_gateway_id             = string
    local_gateway_id           = string
    network_interface_id       = string
    transit_gateway_id         = string
    vpc_endpoint_id            = string
    vpc_peering_connection_id  = string
  }))
  default = []
}
variable "additional_database_routes" {
  type = list(object({
    cidr_block                 = string
    destination_prefix_list_id = string
    ipv6_cidr_block            = string
    carrier_gateway_id         = string
    egress_only_gateway_id     = string
    gateway_id                 = string
    instance_id                = string
    nat_gateway_id             = string
    local_gateway_id           = string
    network_interface_id       = string
    transit_gateway_id         = string
    vpc_endpoint_id            = string
    vpc_peering_connection_id  = string
  }))
  default = []
}
variable "additional_approach_routes" {
  type = list(object({
    cidr_block                 = string
    destination_prefix_list_id = string
    ipv6_cidr_block            = string
    carrier_gateway_id         = string
    egress_only_gateway_id     = string
    gateway_id                 = string
    instance_id                = string
    nat_gateway_id             = string
    local_gateway_id           = string
    network_interface_id       = string
    transit_gateway_id         = string
    vpc_endpoint_id            = string
    vpc_peering_connection_id  = string
  }))
  default = []
}
variable "additional_secure_routes" {
  type = list(object({
    cidr_block                 = string
    destination_prefix_list_id = string
    ipv6_cidr_block            = string
    carrier_gateway_id         = string
    egress_only_gateway_id     = string
    gateway_id                 = string
    instance_id                = string
    nat_gateway_id             = string
    local_gateway_id           = string
    network_interface_id       = string
    transit_gateway_id         = string
    vpc_endpoint_id            = string
    vpc_peering_connection_id  = string
  }))
  default = []
}
variable "additional_workspaces_routes" {
  type = list(object({
    cidr_block                 = string
    destination_prefix_list_id = string
    ipv6_cidr_block            = string
    carrier_gateway_id         = string
    egress_only_gateway_id     = string
    gateway_id                 = string
    instance_id                = string
    nat_gateway_id             = string
    local_gateway_id           = string
    network_interface_id       = string
    transit_gateway_id         = string
    vpc_endpoint_id            = string
    vpc_peering_connection_id  = string
  }))
  default = []
}

// protocol 6 = tcp
// protocol 17 = udp
variable "dmz_ingress_ports" {
  type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default = [
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
      cidr_block = "subnet.0.0/21"
      from_port = 389
      to_port = 389
    },
    {
      rule_no = 151
      protocol = "17"
      rule_action = "allow"
      cidr_block = "subnet.0.0/21"
      from_port = 389
      to_port = 389
    },
    {
      rule_no = 152
      protocol = "6"
      rule_action = "allow"
      cidr_block = "subnet.0.0/21"
      from_port = 88
      to_port = 88
    },
    {
      rule_no = 153
      protocol = "6"
      rule_action = "allow"
      cidr_block = "subnet.0.0/21"
      from_port = 445
      to_port = 445
    },
    {
      rule_no = 154
      protocol = "6"
      rule_action = "allow"
      cidr_block = "subnet.0.0/21"
      from_port = 464
      to_port = 464
    }
  ]
}

variable "internal_ingress_ports" {
  type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default = [
    {
      rule_no     = 90
      protocol    = "-1"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/16"
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
      cidr_block  = "subnet.0.0/21"
      from_port   = 389
      to_port     = 389
    },
    {
      rule_no     = 191
      protocol    = "17"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/21"
      from_port   = 389
      to_port     = 389
    },
    {
      rule_no     = 200
      protocol    = "6"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/21"
      from_port   = 88
      to_port     = 88
    },
    {
      rule_no     = 128
      protocol    = "6"
      rule_action = "deny"
      cidr_block  = "subnet.60.0/22"
      from_port   = 22
      to_port     = 22
    }
  ]
}

variable "database_ingress_ports" {
  type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default = [
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
      cidr_block  = "subnet.0.0/16"
      from_port   = 5432
      to_port     = 5432
    },
    {
      rule_no     = 160
      protocol    = "6"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/16"
      from_port   = 6379
      to_port     = 6379
    },
    {
      rule_no     = 170
      protocol    = "6"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/16"
      from_port   = 27017
      to_port     = 27017
    },
    {
      rule_no     = 180
      protocol    = "6"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/16"
      from_port   = 9096
      to_port     = 9096
    },
    {
      rule_no     = 190
      protocol    = "6"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/16"
      from_port   = 1521
      to_port     = 1526
    }
  ]
}

variable "approach_ingress_ports" {
  type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default = [
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
}

variable "secure_ingress_ports" {
    type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default   = [
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
      cidr_block  = "subnet.0.0/21"
      from_port   = 0
      to_port     = 65535
    }
  ]
}

variable "workspaces_ingress_ports" {
    type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default   = [
    {
      rule_no     = 90
      protocol    = "-1"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/16"
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
}

variable "dmz_egress_ports" {
  type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default         = [
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
      cidr_block  = "subnet.0.0/21"
      from_port   = 389
      to_port     = 389
    },
    {
      rule_no     = 151
      protocol    = "17"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/21"
      from_port   = 389
      to_port     = 389
    },
    {
      rule_no     = 152
      protocol    = "6"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/21"
      from_port   = 88
      to_port     = 88
    },
    {
      rule_no     = 153
      protocol    = "6"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/21"
      from_port   = 445
      to_port     = 445
    },
    {
      rule_no     = 154
      protocol    = "6"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/21"
      from_port   = 464
      to_port     = 464
    }
  ]
}
variable "internal_egress_ports" {
  type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default         = [
    {
      rule_no     = 90
      protocol    = "-1"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/16"
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
      cidr_block  = "subnet.8.0/21"
      from_port   = 5432
      to_port     = 5432
    },
    {
      rule_no     = 190
      protocol    = "6"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/21"
      from_port   = 389
      to_port     = 389
    },
    {
      rule_no     = 191
      protocol    = "17"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/21"
      from_port   = 389
      to_port     = 389
    },
    {
      rule_no     = 200
      protocol    = "6"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/21"
      from_port   = 88
      to_port     = 88
    },
    {
      rule_no     = 128
      protocol    = "6"
      rule_action = "deny"
      cidr_block  = "subnet.60.0/22"
      from_port   = 22
      to_port     = 22
    }
  ]
}

variable "database_egress_ports" {
    type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default    = [
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
      cidr_block  = "subnet.0.0/16"
      from_port   = 1024
      to_port     = 65535
    }
  ]
}

variable "approach_egress_ports" {
    type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default    = [
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
      cidr_block  = "subnet.0.0/16"
      from_port   = 5432
      to_port     = 5432
    }
  ]
}

variable "secure_egress_ports" {
    type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default    = [
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
      cidr_block  = "subnet.0.0/16"
      from_port   = 5432
      to_port     = 5432
    },
    {
      rule_no     = 160
      protocol    = "6"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/21"
      from_port   = 0
      to_port     = 65535
    }
  ]
}

variable "workspaces_egress_ports" {
  type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default = [
    {
      rule_no     = 90
      protocol    = "-1"
      rule_action = "allow"
      cidr_block  = "subnet.0.0/16"
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
}

variable "additional_internal_ingress_ports" {
  type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default = []
}

variable "additional_workspaces_ingress_ports" {
  type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default = []
}

variable "additional_approach_ingress_ports" {
  type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default = []
}

variable "additional_database_ingress_ports" {
  type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default = []
}

variable "additional_internal_egress_ports" {
  type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default = []
}

variable "additional_workspaces_egress_ports" {
  type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default = []
}

variable "additional_approach_egress_ports" {
  type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default = []
}

variable "additional_database_egress_ports" {
  type = list(object({
    rule_no = number
    protocol = string
    rule_action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))

  default = []
}