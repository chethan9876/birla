locals {
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  endpoint_type = lower(var.endpoint_type)
  prefix = "${local.environment}-${local.client}-${var.service_name}-${local.endpoint_type}-endpoint"

  vpc_endpoint_name = "${local.prefix}-vpc"
}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.${var.service_name}"
  vpc_endpoint_type = var.endpoint_type
  security_group_ids = var.endpoint_type == "Interface" && length(aws_security_group.interface_endpoint_security_group) > 0 ? [aws_security_group.interface_endpoint_security_group[0].id] : null
  private_dns_enabled = var.endpoint_type == "Interface" && var.service_name != "s3" ? true : null
  subnet_ids = var.endpoint_type == "Interface" ? var.subnet_ids : null
  route_table_ids = var.endpoint_type == "Gateway" ? var.route_table_ids : null
  tags = {
    environment = local.environment
    Name = local.vpc_endpoint_name
    Client = local.client
  }
}

data "aws_network_interface" "network_interfaces_0" {
  count = var.endpoint_type == "Gateway" ? 0 : 1
  id    = tolist(aws_vpc_endpoint.vpc_endpoint.network_interface_ids)[0]
}

data "aws_network_interface" "network_interfaces_1" {
  count = var.endpoint_type == "Gateway" ? 0 : 1
  id    = tolist(aws_vpc_endpoint.vpc_endpoint.network_interface_ids)[1]
}

data "aws_network_interface" "network_interfaces_2" {
  count = var.endpoint_type == "Gateway" ? 0 : 1
  id    = tolist(aws_vpc_endpoint.vpc_endpoint.network_interface_ids)[2]
}