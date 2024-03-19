locals {
  client      = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))

 }

//provider "aws" {
//  profile = var.profile
//  region  = var.region
//  ignore_tags {
//    key_prefixes = ["kubernetes.io/"]
//  }
//}

resource "aws_route53_resolver_endpoint" "route53_resolver_endpoint_outbound" {
  direction = "OUTBOUND"
  name      = ("${var.environment}-${var.client}-outboundendpoint-r53")
  security_group_ids = [
        aws_security_group.route53_endpoint_security_group.id    ]

  dynamic ip_address {
    for_each = var.endpoint_subnets
    iterator = subnet
    content {
      subnet_id = subnet.value
    }
  }

  tags = {
    Name = ("${var.environment}-${var.client}-resolverendpoint-r53")
    Environment = var.environment
    Client = var.client
  }
}

