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

resource "aws_route53_resolver_rule" "route53_resolver_rule" {
  name      = ("${var.environment}-${var.client}-rule-${var.description}-r53")
  rule_type   = "FORWARD"
  domain_name = var.domain_name
  resolver_endpoint_id = var.resolver_endpoint_id
  target_ip {
    ip = var.target_ip1
  }
  
  tags = {
    Name      = ("${var.environment}-${var.client}-rule-${var.description}-r53_resolverrule") 
    Client = local.client
    environment = local.environment

  }
}
