locals {
  application = var.application
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  prefix = "${local.environment}-${local.client}-${local.application}"
}

module "rest_api_nlb" {
  source = "../../load_balancer"
  application = local.application
  client = local.client
  environment = local.environment
  function = "rest-api"
  subnet_ids = var.subnet_ids
  lb_type = "network"
  certificate_arn = var.certificate_arn
  vpc_id = var.vpc_id
  target_type = "alb"
  port = 443
  protocol = "TCP"
}

module "vpce" {
  source = "../../vpc_endpoint"
  client = local.client
  environment = local.environment
  region = var.region
  endpoint_type = "Interface"
  vpc_id = var.vpc_id
  service_name = "execute-api"
  subnet_ids = var.subnet_ids
}

resource "aws_api_gateway_vpc_link" "rest_api_vpc_link" {
  name        = "${local.prefix}-rest-api-vpc-link"
  description = "${local.prefix}-rest-api-vpc-link"
  target_arns = [module.rest_api_nlb.load_balancer_arn]

  tags = {
    Name = "${local.prefix}-rest-api-vpc-link"
    Client = var.client
    Application = var.application
    Environment = var.environment
  }
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name = "${local.prefix}-private-rest-api"

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = [module.vpce.vpce_id]
  }

  policy = data.aws_iam_policy_document.rest_api_poicy.json

  tags = {
    Name = "${local.prefix}-rest-api"
    Client = var.client
    Application = var.application
    Environment = var.environment
  }
}

resource "aws_api_gateway_deployment" "rest_api" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "rest_api" {
  deployment_id = aws_api_gateway_deployment.rest_api.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = "default"

  tags = {
    Name = "${local.prefix}-rest-api-stage"
    Client = var.client
    Application = var.application
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "rest_api_poicy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["execute-api:Invoke"]
    resources = ["*"]
  }
}

//resource "aws_api_gateway_rest_api_policy" "test" {
//  rest_api_id = aws_api_gateway_rest_api.rest_api.id
//  policy      = data.aws_iam_policy_document.rest_api_poicy.json
//}