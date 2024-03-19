module "s3_gateway_endpoint" {
  source = "../../templates/vpc_endpoint"
  client = local.client
  endpoint_type = "Gateway"
  environment = local.environment
  region = var.region
  service_name = "s3"
  vpc_id = var.vpc_id
  route_table_ids = [var.internal_route_table_id]
}

module "sqs_interface_endpoint" {
  source = "../../templates/vpc_endpoint"
  client = local.client
  endpoint_type = "Interface"
  environment = local.environment
  region = var.region
  service_name = "sqs"
  vpc_id = var.vpc_id
  //TODO: review this.
  //security_group_ids = [module.eks.cluster_security_group_id]
  subnet_ids = var.subnet_ids
}