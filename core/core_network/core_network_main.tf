locals {
  application = "core-network"
  client      = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  prefix      = "${local.environment}-${local.client}-${local.application}"
  vpc_cidr    = var.vpc_cidr == "" ? "${var.subnet_short}.0.0/16" : var.vpc_cidr
  subnets_dmz = {
    for k, v in var.subnets_dmz :
      length(split("region-", k)) > 1 ? "${var.region}${split("region-", k)[1]}" : k => length(split("subnet", v)) > 1 ? "${var.subnet_short}${split("subnet", v)[1]}" : v
  }
  subnets_internal = {
    for k, v in var.subnets_internal :
      length(split("region-", k)) > 1 ? "${var.region}${split("region-", k)[1]}" : k => length(split("subnet", v)) > 1 ? "${var.subnet_short}${split("subnet", v)[1]}" : v
  }
  subnets_database = {
    for k, v in var.subnets_database :
      length(split("region-", k)) > 1 ? "${var.region}${split("region-", k)[1]}" : k => length(split("subnet", v)) > 1 ? "${var.subnet_short}${split("subnet", v)[1]}" : v
  }
  subnets_approach = {
    for k, v in var.subnets_approach :
      length(split("region-", k)) > 1 ? "${var.region}${split("region-", k)[1]}" : k => length(split("subnet", v)) > 1 ? "${var.subnet_short}${split("subnet", v)[1]}" : v
  }
  subnets_secure = {
    for k, v in var.subnets_secure :
      length(split("region-", k)) > 1 ? "${var.region}${split("region-", k)[1]}" : k => length(split("subnet", v)) > 1 ? "${var.subnet_short}${split("subnet", v)[1]}" : v
  }
  subnets_workspaces = {
    for k, v in var.subnets_workspaces :
      length(split("region-", k)) > 1 ? "${var.region}${split("region-", k)[1]}" : k => length(split("subnet", v)) > 1 ? "${var.subnet_short}${split("subnet", v)[1]}" : v
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
  ignore_tags {
    key_prefixes = ["kubernetes.io/"]
  }
}

resource "aws_vpc" "main" {
  enable_dns_hostnames = true
  cidr_block           = local.vpc_cidr
  instance_tenancy     = var.vpc_instance_tenancy

  tags = {
    Name = ("${var.environment}-${var.client}-vpc")
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  count      = var.additional_vpc_cidr == "" ? 0 : 1
  vpc_id     = aws_vpc.main.id
  cidr_block = var.additional_vpc_cidr
}

resource "aws_vpc_dhcp_options" "main_dhcp_options" {
  domain_name_servers = ["AmazonProvidedDNS"]
  ntp_servers         = ["169.254.169.123"]
  domain_name         = ("${var.region}.compute.internal")

  tags = {
    Name = "${var.environment}-${var.client}-dhcp-options"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main_dhcp_options.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = {
    Name = ("${var.environment}-${var.client}igw")
  }
}
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.subnets_dmz)[0].id
  depends_on    = [aws_eip.nat, aws_subnet.subnets_dmz, aws_internet_gateway.igw]
  tags          = {
    Name = ("${var.environment}-${var.client}-ngw-az-a")
  }
}
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_route_table" "route_dmz" {
  vpc_id     = aws_vpc.main.id
  depends_on = [aws_nat_gateway.ngw]

  dynamic "route" {
    for_each = concat(var.dmz_routes, var.additional_dmz_routes)
    content {
      cidr_block                 = lookup(route.value, "cidr_block", null)
      destination_prefix_list_id = lookup(route.value, "destination_prefix_list_id", null)
      ipv6_cidr_block            = lookup(route.value, "ipv6_cidr_block", null)
      carrier_gateway_id         = lookup(route.value, "carrier_gateway_id", null)
      egress_only_gateway_id     = lookup(route.value, "egress_only_gateway_id", null)
      gateway_id                 = route.value.cidr_block == "0.0.0.0/0" ? aws_internet_gateway.igw.id : lookup(route.value, "gateway_id", null)
      instance_id                = lookup(route.value, "instance_id", null)
      nat_gateway_id             = lookup(route.value, "nat_gateway_id", null)
      local_gateway_id           = lookup(route.value, "local_gateway_id", null)
      network_interface_id       = lookup(route.value, "network_interface_id", null)
      transit_gateway_id         = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id            = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id  = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }
  tags       = {
    Name = ("${var.environment}-${var.client}-dmz-rt")
  }
}
resource "aws_route_table" "route_internal" {
  vpc_id     = aws_vpc.main.id
  depends_on = [aws_nat_gateway.ngw]

  dynamic "route" {
    for_each = concat(var.internal_routes, var.additional_internal_routes)
    content {
      cidr_block                 = lookup(route.value, "cidr_block", null)
      destination_prefix_list_id = lookup(route.value, "destination_prefix_list_id", null)
      ipv6_cidr_block            = lookup(route.value, "ipv6_cidr_block", null)
      carrier_gateway_id         = lookup(route.value, "carrier_gateway_id", null)
      egress_only_gateway_id     = lookup(route.value, "egress_only_gateway_id", null)
      gateway_id                 = lookup(route.value, "gateway_id", null)
      instance_id                = lookup(route.value, "instance_id", null)
      nat_gateway_id             = route.value.cidr_block == "0.0.0.0/0" ? aws_nat_gateway.ngw.id : lookup(route.value, "nat_gateway_id", null)
      local_gateway_id           = lookup(route.value, "local_gateway_id", null)
      network_interface_id       = lookup(route.value, "network_interface_id", null)
      transit_gateway_id         = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id            = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id  = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }
  tags       = {
    Name = ("${var.environment}-${var.client}-internal-rt")
  }
}
resource "aws_route_table" "route_database" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = concat(var.database_routes, var.additional_database_routes)
    content {
      cidr_block     = route.value.cidr_block
      nat_gateway_id = route.value.cidr_block == "0.0.0.0/0" ? aws_nat_gateway.ngw.id : lookup(route.value, "nat_gateway_id", null)
      gateway_id = route.value.gateway_id
      destination_prefix_list_id = route.value.destination_prefix_list_id
      ipv6_cidr_block = route.value.ipv6_cidr_block
      carrier_gateway_id = route.value.carrier_gateway_id
      egress_only_gateway_id = route.value.egress_only_gateway_id
      instance_id = route.value.instance_id
      local_gateway_id = route.value.local_gateway_id
      network_interface_id = route.value.network_interface_id
      transit_gateway_id = route.value.transit_gateway_id
      vpc_endpoint_id =  route.value.vpc_endpoint_id
      vpc_peering_connection_id = route.value.vpc_peering_connection_id

    }
  }
  tags = {
    Name = ("${var.environment}-${var.client}-database-rt")
  }
}
resource "aws_route_table" "route_approach" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = concat(var.approach_routes, var.additional_approach_routes)
    content {
      cidr_block     = route.value.cidr_block
      nat_gateway_id = route.value.cidr_block == "0.0.0.0/0" ? aws_nat_gateway.ngw.id : lookup(route.value, "nat_gateway_id", null)
      gateway_id = route.value.gateway_id
      destination_prefix_list_id = route.value.destination_prefix_list_id
      ipv6_cidr_block = route.value.ipv6_cidr_block
      carrier_gateway_id = route.value.carrier_gateway_id
      egress_only_gateway_id = route.value.egress_only_gateway_id
      instance_id = route.value.instance_id
      local_gateway_id = route.value.local_gateway_id
      network_interface_id = route.value.network_interface_id
      transit_gateway_id = route.value.transit_gateway_id
      vpc_endpoint_id =  route.value.vpc_endpoint_id
      vpc_peering_connection_id = route.value.vpc_peering_connection_id
    }
  }
  tags = {
    Name = ("${var.environment}-${var.client}-approach-rt")
  }
}
resource "aws_route_table" "route_secure" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = concat(var.secure_routes, var.additional_secure_routes)
    content {
      cidr_block     = route.value.cidr_block
      nat_gateway_id = route.value.cidr_block == "0.0.0.0/0" ? aws_nat_gateway.ngw.id : lookup(route.value, "nat_gateway_id", null)
      gateway_id = route.value.gateway_id
      destination_prefix_list_id = route.value.destination_prefix_list_id
      ipv6_cidr_block = route.value.ipv6_cidr_block
      carrier_gateway_id = route.value.carrier_gateway_id
      egress_only_gateway_id = route.value.egress_only_gateway_id
      instance_id = route.value.instance_id
      local_gateway_id = route.value.local_gateway_id
      network_interface_id = route.value.network_interface_id
      transit_gateway_id = route.value.transit_gateway_id
      vpc_endpoint_id =  route.value.vpc_endpoint_id
      vpc_peering_connection_id = route.value.vpc_peering_connection_id
    }
  }
  tags = {
    Name = ("${var.environment}-${var.client}-secure-rt")
  }
}
resource "aws_route_table" "route_workspaces" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = concat(var.workspaces_routes, var.additional_workspaces_routes)
    content {
      cidr_block     = route.value.cidr_block
      nat_gateway_id = route.value.cidr_block == "0.0.0.0/0" ? aws_nat_gateway.ngw.id : lookup(route.value, "nat_gateway_id", null)
      gateway_id = route.value.gateway_id
      destination_prefix_list_id = route.value.destination_prefix_list_id
      ipv6_cidr_block = route.value.ipv6_cidr_block
      carrier_gateway_id = route.value.carrier_gateway_id
      egress_only_gateway_id = route.value.egress_only_gateway_id
      instance_id = route.value.instance_id
      local_gateway_id = route.value.local_gateway_id
      network_interface_id = route.value.network_interface_id
      transit_gateway_id = route.value.transit_gateway_id
      vpc_endpoint_id =  route.value.vpc_endpoint_id
      vpc_peering_connection_id = route.value.vpc_peering_connection_id
    }
  }
  tags = {
    Name = ("${var.environment}-${var.client}-workspaces-rt")
  }
}

resource "aws_network_acl" "acl_dmz" {
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.dmz_ingress_ports
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = ingress.value.rule_action
      cidr_block = length(split("subnet", ingress.value.cidr_block)) > 1 ? "${var.subnet_short}${split("subnet", ingress.value.cidr_block)[1]}" : ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }
  dynamic "egress" {
    for_each = var.dmz_egress_ports
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = egress.value.rule_action
      cidr_block = length(split("subnet", egress.value.cidr_block)) > 1 ? "${var.subnet_short}${split("subnet", egress.value.cidr_block)[1]}" : egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  subnet_ids = values(aws_subnet.subnets_dmz)[*].id

  tags = {
    Name = ("${var.environment}-${var.client}-dmz-acl")
  }
}
resource "aws_network_acl" "acl_internal" {
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = concat(var.internal_ingress_ports, var.additional_internal_ingress_ports)
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = ingress.value.rule_action
      cidr_block = length(split("subnet", ingress.value.cidr_block)) > 1 ? "${var.subnet_short}${split("subnet", ingress.value.cidr_block)[1]}" : ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
      icmp_code  = ingress.value.protocol == "1" ? "-1" : null
      icmp_type  = ingress.value.protocol == "1" ? "-1" : null
    }
  }
  dynamic "egress" {
    for_each = concat(var.internal_egress_ports, var.additional_internal_egress_ports)
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = egress.value.rule_action
      cidr_block = length(split("subnet", egress.value.cidr_block)) > 1 ? "${var.subnet_short}${split("subnet", egress.value.cidr_block)[1]}" : egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
      icmp_code  = egress.value.protocol == "1" ? "-1" : null
      icmp_type  = egress.value.protocol == "1" ? "-1" : null
    }
  }

  subnet_ids = values(aws_subnet.subnets_internal)[*].id

  tags = {
    Name = ("${var.environment}-${var.client}-internal-acl")
  }
}
resource "aws_network_acl" "acl_database" {
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = concat(var.database_ingress_ports, var.additional_database_ingress_ports)
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = ingress.value.rule_action
      cidr_block = length(split("subnet", ingress.value.cidr_block)) > 1 ? "${var.subnet_short}${split("subnet", ingress.value.cidr_block)[1]}" : ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }
  dynamic "egress" {
    for_each = concat(var.database_egress_ports, var.additional_database_egress_ports)
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = egress.value.rule_action
      cidr_block = length(split("subnet", egress.value.cidr_block)) > 1 ? "${var.subnet_short}${split("subnet", egress.value.cidr_block)[1]}" : egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  subnet_ids = values(aws_subnet.subnets_database)[*].id

  tags = {
    Name = ("${var.environment}-${var.client}-database-acl")
  }
}
resource "aws_network_acl" "acl_approach" {
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = concat(var.approach_ingress_ports, var.additional_approach_ingress_ports)
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = ingress.value.rule_action
      cidr_block = length(split("subnet", ingress.value.cidr_block)) > 1 ? "${var.subnet_short}${split("subnet", ingress.value.cidr_block)[1]}" : ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }
  dynamic "egress" {
    for_each = concat(var.approach_egress_ports, var.additional_approach_egress_ports)
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = egress.value.rule_action
      cidr_block = length(split("subnet", egress.value.cidr_block)) > 1 ? "${var.subnet_short}${split("subnet", egress.value.cidr_block)[1]}" : egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  subnet_ids = values(aws_subnet.subnets_approach)[*].id

  tags = {
    Name = ("${var.environment}-${var.client}-approach-acl")
  }
}
resource "aws_network_acl" "acl_secure" {
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.secure_ingress_ports
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = ingress.value.rule_action
      cidr_block = length(split("subnet", ingress.value.cidr_block)) > 1 ? "${var.subnet_short}${split("subnet", ingress.value.cidr_block)[1]}" : ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }
  dynamic "egress" {
    for_each = var.secure_egress_ports
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = egress.value.rule_action
      cidr_block = length(split("subnet", egress.value.cidr_block)) > 1 ? "${var.subnet_short}${split("subnet", egress.value.cidr_block)[1]}" : egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  subnet_ids = values(aws_subnet.subnets_secure)[*].id

  tags = {
    Name = ("${var.environment}-${var.client}-secure-acl")
  }
}
resource "aws_network_acl" "acl_workspaces" {
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = concat(var.workspaces_ingress_ports, var.additional_workspaces_ingress_ports)
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = ingress.value.rule_action
      cidr_block = length(split("subnet", ingress.value.cidr_block)) > 1 ? "${var.subnet_short}${split("subnet", ingress.value.cidr_block)[1]}" : ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }
  dynamic "egress" {
    for_each = concat(var.workspaces_egress_ports, var.additional_workspaces_egress_ports)
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = egress.value.rule_action
      cidr_block = length(split("subnet", egress.value.cidr_block)) > 1 ? "${var.subnet_short}${split("subnet", egress.value.cidr_block)[1]}" : egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  subnet_ids = values(aws_subnet.subnets_workspaces)[*].id

  tags = {
    Name = ("${var.environment}-${var.client}-workspaces-acl")
  }
}

resource "aws_subnet" "subnets_dmz" {
  for_each                = local.subnets_dmz
  availability_zone       = each.key
  cidr_block              = each.value
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = "true"
  tags                    = {
    Name        = ("${var.environment}-${var.client}-dmz-${substr(each.key,-1,1)}-sub")
    subnet-type = "dmz"
  }
}
resource "aws_subnet" "subnets_internal" {
  for_each          = local.subnets_internal
  availability_zone = each.key
  cidr_block        = each.value
  vpc_id            = aws_vpc.main.id
  tags              = {
    Name        = ("${var.environment}-${var.client}-internal-${substr(each.key,-1,1)}-sub")
    subnet-type = "internal"
  }
}
resource "aws_subnet" "subnets_database" {
  for_each          = local.subnets_database
  availability_zone = each.key
  cidr_block        = each.value
  vpc_id            = aws_vpc.main.id
  tags              = {
    Name        = ("${var.environment}-${var.client}-database-${substr(each.key,-1,1)}-sub")
    subnet-type = "database"
  }
}
resource "aws_subnet" "subnets_approach" {
  for_each          = local.subnets_approach
  availability_zone = each.key
  cidr_block        = each.value
  vpc_id            = aws_vpc.main.id
  tags              = {
    Name        = ("${var.environment}-${var.client}-approach-${substr(each.key,-1,1)}-sub")
    subnet-type = "approach"
  }
}
resource "aws_subnet" "subnets_secure" {
  for_each          = local.subnets_secure
  availability_zone = each.key
  cidr_block        = each.value
  vpc_id            = aws_vpc.main.id
  tags              = {
    Name        = ("${var.environment}-${var.client}-secure-${substr(each.key,-1,1)}-sub")
    subnet-type = "secure"
  }
}
resource "aws_subnet" "subnets_workspaces" {
  for_each                = local.subnets_workspaces
  availability_zone       = each.key
  cidr_block              = each.value
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = "true"
  tags                    = {
    Name        = ("${var.environment}-${var.client}-workspaces-${substr(each.key,-1,1)}-sub")
    subnet-type = "workspaces"
  }
}

resource "aws_route_table_association" "dmz_route_table_association" {
  for_each       = aws_subnet.subnets_dmz
  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_dmz.id
  depends_on     = [aws_subnet.subnets_dmz, aws_route_table.route_dmz]
}
resource "aws_route_table_association" "internal_route_table_association" {
  for_each       = aws_subnet.subnets_internal
  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_internal.id
  depends_on     = [aws_subnet.subnets_internal, aws_route_table.route_internal]
}
resource "aws_route_table_association" "database_route_table_association" {
  for_each       = aws_subnet.subnets_database
  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_database.id
  depends_on     = [aws_subnet.subnets_database, aws_route_table.route_database]
}
resource "aws_route_table_association" "approach_route_table_association" {
  for_each       = aws_subnet.subnets_approach
  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_approach.id
  depends_on     = [aws_subnet.subnets_approach, aws_route_table.route_approach]
}
resource "aws_route_table_association" "secure_route_table_association" {
  for_each       = aws_subnet.subnets_secure
  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_secure.id
  depends_on     = [aws_subnet.subnets_secure, aws_route_table.route_secure]
}
resource "aws_route_table_association" "workspaces_route_table_association" {
  for_each       = aws_subnet.subnets_workspaces
  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_workspaces.id
  depends_on     = [aws_subnet.subnets_workspaces, aws_route_table.route_workspaces]
}

resource "aws_security_group" "internet_sg" {
  name        = ("${var.environment}-${var.client}-internet-sg")
  description = "Internet Access"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = ("${var.environment}-${var.client}-internet-sg")
  }
}

resource "aws_db_subnet_group" "common_db_subnet_group" {
  name       = "${local.prefix}-db-subnet-group"
  subnet_ids = values(aws_subnet.subnets_database)[*].id

  tags = {
    Name        = "${local.prefix}-db-subnet-group"
    Environment = local.environment
    Application = local.application
  }
}

resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id            = aws_vpc.main.id
  tags = {
    Name        = ("${var.environment}-${var.client}-gateway-vpn")
  }
}

resource "aws_vpn_gateway_attachment" "vpn_gateway_attachment" {
  vpc_id         = aws_vpc.main.id
  vpn_gateway_id = aws_vpn_gateway.vpn_gateway.id
}