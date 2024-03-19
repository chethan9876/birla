module "api" {
  source = "../../templates/api/http"
  client = var.client
  environment = var.environment
  application = local.application
  domain = var.domain
  certificate_arn = var.certificate_arn
  vpc_id = var.vpc_id
  hosted_zone_id = var.hosted_zone_id
  vpc_internal_cidr = var.vpc_internal_cidr
  region = var.region
  whitelist_ips = var.api_whitelist_ips
}