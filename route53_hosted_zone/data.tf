data "aws_route53_zone" "domain" {
  name = var.root_domain
  provider = aws.route53
}

locals {
  root_domain_id = data.aws_route53_zone.domain.id
}