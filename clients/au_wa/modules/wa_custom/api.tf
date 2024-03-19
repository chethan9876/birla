module "rest_api" {
  source = "../../../../templates/api/rest"
  application = local.application
  client = local.client
  environment = local.environment
  region = local.region
  certificate_arn = var.certificate_arn
  vpc_id = var.vpc_id
  subnet_ids = var.internal_subnet_ids
}

module "vpce_svc" {
  source = "../../../../templates/vpc_endpoint_svc"
  application = local.application
  client = local.client
  environment = local.environment
  name = "api-gateway"
  certificate_arn = var.certificate_arn
  vpc_id = var.vpc_id
  allowed_principals = var.vpce_svc_allowed_accounts
  subnet_ids = var.internal_subnet_ids
  vpce_network_interface_ip_1 = module.rest_api.vpce_network_interface_ip_1
  vpce_network_interface_ip_2 = module.rest_api.vpce_network_interface_ip_2
  vpce_network_interface_ip_3 = module.rest_api.vpce_network_interface_ip_3
  private_dns_name = "api-service.${local.environment}.${var.domain}"
  zone_id = var.hosted_zone_id
}

#TODO: remove after testing for rest-api has been finalised
resource "aws_api_gateway_resource" "reference_data" {
  rest_api_id = module.rest_api.rest_api_id
  parent_id   = module.rest_api.rest_api_root_resource_id
  path_part   = "reference-data"
}

module "api_resource_locations" {
  source = "../../../../templates/api/rest_resource"
  vpc_link_id = module.rest_api.vpc_link_id
  rest_api_id = module.rest_api.rest_api_id
  parent_resource_id = aws_api_gateway_resource.reference_data.id
  authorisation = local.authorisation
  integration_url = "https://referencr-alb.${local.environment}.${var.domain}/reference-data/locations"
  path = "locations"
}

# /infringements
module "api_resource_infringements" {
  source = "../../../../templates/api/rest_resource"
  vpc_link_id = module.rest_api.vpc_link_id
  rest_api_id = module.rest_api.rest_api_id
  parent_resource_id = module.rest_api.rest_api_root_resource_id
  authorisation = local.authorisation
  integration_url = "https://dotinterfacr-alb.${local.environment}.${var.domain}/infringements"
  path = "infringements"
}

# /infringements/{infringementNumber}
module "api_resource_infringement_no" {
  source = "../../../../templates/api/rest_resource"
  vpc_link_id = module.rest_api.vpc_link_id
  rest_api_id = module.rest_api.rest_api_id
  parent_resource_id = module.api_resource_infringements.resource_id
  authorisation = local.authorisation
  integration_url = "https://dotinterfacr-alb.${local.environment}.${var.domain}/infringements/{proxy}"
  path = "{proxy+}"
  integration_type = "HTTP_PROXY"
}

# /financial-transactions
module "api_resource_financial_transactions" {
  source = "../../../../templates/api/rest_resource_sqs"
  vpc_link_id = module.rest_api.vpc_link_id
  rest_api_id = module.rest_api.rest_api_id
  parent_resource_id = module.rest_api.rest_api_root_resource_id
  authorisation = local.authorisation
  integration_url = "https://referencr-alb.${local.environment}.${var.domain}/reference-data/locations"
  path = "financial-transactions"
  region = var.region
  queue_name = module.payment_received_events.sqs_queue_name
  role_arn = aws_iam_role.api_gateway_sqs.arn
}

# /driver-identification-requests/{infringementNumber}
resource "aws_api_gateway_resource" "driver_identification_requests" {
  rest_api_id = module.rest_api.rest_api_id
  parent_id   = module.rest_api.rest_api_root_resource_id
  path_part   = "driver-identification-requests"
}

module "api_resource_driver_identification_requests" {
  source = "../../../../templates/api/rest_resource"
  vpc_link_id = module.rest_api.vpc_link_id
  rest_api_id = module.rest_api.rest_api_id
  parent_resource_id = aws_api_gateway_resource.driver_identification_requests.id
  authorisation = local.authorisation
  integration_url = "https://dotinterfacr-alb.${local.environment}.${var.domain}/driver-identification-requests/{proxy}"
  path = "{proxy+}"
  integration_type = "HTTP_PROXY"
  http_method = "POST"
}

# /driver-identification-rejections/{infringementNumber}
resource "aws_api_gateway_resource" "driver_identification_rejections" {
  rest_api_id = module.rest_api.rest_api_id
  parent_id   = module.rest_api.rest_api_root_resource_id
  path_part   = "driver-identification-rejections"
}

module "api_resource_driver_identification_rejections" {
  source = "../../../../templates/api/rest_resource"
  vpc_link_id = module.rest_api.vpc_link_id
  rest_api_id = module.rest_api.rest_api_id
  parent_resource_id = aws_api_gateway_resource.driver_identification_rejections.id
  authorisation = local.authorisation
  integration_url = "https://dotinterfacr-alb.${local.environment}.${var.domain}/driver-identification-rejections/{proxy}"
  path = "{proxy+}"
  integration_type = "HTTP_PROXY"
  http_method = "POST"
}
# /payment-extension-request/{infringementNumber}
resource "aws_api_gateway_resource" "payment_extension_request" {
  rest_api_id = module.rest_api.rest_api_id
  parent_id   = module.rest_api.rest_api_root_resource_id
  path_part   = "payment-extension-request"
}

module "api_resource_payment_extension_request" {
  source = "../../../../templates/api/rest_resource"
  vpc_link_id = module.rest_api.vpc_link_id
  rest_api_id = module.rest_api.rest_api_id
  parent_resource_id = aws_api_gateway_resource.payment_extension_request.id
  authorisation = local.authorisation
  integration_url = "https://dotinterfacr-alb.${local.environment}.${var.domain}/payment-extension-request/{proxy}"
  path = "{proxy+}"
  integration_type = "HTTP_PROXY"
  http_method = "POST"
}

resource "aws_api_gateway_resource" "vehicle_sold_advices" {
  rest_api_id = module.rest_api.rest_api_id
  parent_id   = module.rest_api.rest_api_root_resource_id
  path_part   = "vehicle-sold-advices"
}
module "api_resource_vehicle_sold_advices" {
  source = "../../../../templates/api/rest_resource"
  vpc_link_id = module.rest_api.vpc_link_id
  rest_api_id = module.rest_api.rest_api_id
  parent_resource_id = aws_api_gateway_resource.vehicle_sold_advices.id
  authorisation = local.authorisation
  integration_url = "https://dotinterfacr-alb.${local.environment}.${var.domain}/vehicle_sold_advices/{proxy}"
  path = "{proxy+}"
  integration_type = "HTTP_PROXY"
  http_method = "POST"
}

resource "aws_api_gateway_resource" "domestic-violence-appeals" {
  rest_api_id = module.rest_api.rest_api_id
  parent_id   = module.rest_api.rest_api_root_resource_id
  path_part   = "domestic-violence-appeals"
}
module "api_resource_domestic-violence-appeals" {
  source = "../../../../templates/api/rest_resource"
  vpc_link_id = module.rest_api.vpc_link_id
  rest_api_id = module.rest_api.rest_api_id
  parent_resource_id = aws_api_gateway_resource.domestic-violence-appeals.id
  authorisation = local.authorisation
  integration_url = "https://dotinterfacr-alb.${local.environment}.${var.domain}/domestic-violence-appeals/{proxy}"
  path = "{proxy+}"
  integration_type = "HTTP_PROXY"
  http_method = "POST"
}