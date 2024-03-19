locals {
  application = lower(trimspace(var.application))
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
}


provider aws {
  profile = var.client
  region = var.region
}

provider aws {
  alias = "route53"
  profile = var.client == "us-govcloud" ? "us-govcloud-parent" : var.client
  region = "us-east-1"
}


resource "aws_route53_zone" "hosted_zone" {
  name = "${var.subdomain}.${var.root_domain}"
  provider = aws.route53

  tags = {
    Environment = local.environment
    Client = local.client
      Application = local.application
    Name = "${var.subdomain}.${var.root_domain}"
  }
}

resource "aws_route53_record" "hosted_zone_records" {
  zone_id = local.root_domain_id
  provider = aws.route53
  name = "${var.subdomain}.${var.root_domain}"
  type = "NS"
  ttl = "30"

  records = [
    aws_route53_zone.hosted_zone.name_servers.0,
    aws_route53_zone.hosted_zone.name_servers.1,
    aws_route53_zone.hosted_zone.name_servers.2,
    aws_route53_zone.hosted_zone.name_servers.3,
  ]
}