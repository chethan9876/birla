locals {
  application = lower(trimspace(var.application))
  client      = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  name        = "${local.environment}-${local.client}-${local.application}-sftp"
}

resource "aws_transfer_server" "sftp_server" {
  endpoint_type          = "VPC"
  domain                 = var.sftp_domain
  protocols              = ["SFTP"]
  certificate            = var.certificate_arn
  identity_provider_type = "SERVICE_MANAGED"
  url                    = ""

  endpoint_details {
    subnet_ids = [
    var.subnet]
    vpc_id                 = var.vpc_id
    security_group_ids     = [aws_security_group.sftp_security_group.id]
    address_allocation_ids = var.domain_type == "internal" ? [] : [module.eip[0].eip_allocation_id]
  }

  tags = {
    Name                           = "${local.name}"
    Client                         = var.client
    Environment                    = var.environment
    "transfer:customHostname"      = "sftp.${var.hosted_zone_name}"
    "transfer:route53HostedZoneId" = "/hostedzone/${var.hosted_zone_id}"
  }
}

resource "aws_route53_record" "sftp" {
  zone_id = var.hosted_zone_id
  name    = "sftp.${var.hosted_zone_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_transfer_server.sftp_server.endpoint]
}

resource "aws_security_group" "sftp_security_group" {
  name        = "${local.name}-sg"
  vpc_id      = var.vpc_id
  description = "${local.name} security group"

  tags = {
    Name        = "${local.name}-sg"
    Client      = var.client
    Environment = var.environment
  }
}

module "eip" {
  source      = "../../eip"
  count       = var.domain_type == "internal" ? 0 : 1
  application = local.application
  client      = local.client
  environment = local.environment
}