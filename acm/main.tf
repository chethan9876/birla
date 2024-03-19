locals {
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  acm_cert_name = "${local.environment}-${local.client}-acm"
}

provider aws {
  alias = "route53"
  profile = var.client == "us-govcloud" ? "us-govcloud-parent" : var.client
  region = "us-east-1"
}

resource "aws_acm_certificate" "acm_certificate" {
  domain_name = var.domain_name
  subject_alternative_names = [
    "*.${var.domain_name}"]
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "${local.acm_cert_name}-ac"
    environment = local.environment
    Client = local.client
  }
}

resource "aws_route53_record" "route53_record" {
  provider = aws.route53
  for_each = {
    for dvo in aws_acm_certificate.acm_certificate.domain_validation_options : dvo.domain_name => {
      name = dvo.resource_record_name
      record = dvo.resource_record_value
      type = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name = each.value.name
  type = each.value.type
  zone_id = var.hosted_zone_id
  records = [
    each.value.record]
  ttl = 60
}

resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = [
    for record in aws_route53_record.route53_record : record.fqdn]
  timeouts {
    create = "20m"
  }
}