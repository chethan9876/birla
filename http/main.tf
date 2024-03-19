locals {
  application = var.application
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  prefix = "${local.environment}-${local.client}-${local.application}"
}

resource "aws_apigatewayv2_api" "apigateway" {
  name          = "${local.prefix}-api"
  protocol_type = "HTTP"
}

resource "aws_security_group" "sg_vpclink" {
  name        = "${local.prefix}-vpc-link-sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "sg from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.vpc_internal_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.prefix}-vpc-link"
    Client = var.client
    Application = var.application
    Environment = var.environment
  }
}

data "aws_subnet_ids" "selected" {
  vpc_id      = var.vpc_id
  filter {
    name   = "tag:subnet-type"
    values = ["internal"]
  }
}

resource "aws_apigatewayv2_vpc_link" "apiendpoint" {
  name               = "${local.prefix}-vpc-link"
  security_group_ids = [aws_security_group.sg_vpclink.id]
  subnet_ids         = data.aws_subnet_ids.selected.ids
}

resource "aws_apigatewayv2_domain_name" "api" {
  domain_name = "api.${var.environment}.${var.domain}"

  domain_name_configuration {
    certificate_arn = var.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_route53_record" "api" {
  name    = aws_apigatewayv2_domain_name.api.domain_name
  type    = "A"
  zone_id = var.hosted_zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  api_id      = aws_apigatewayv2_api.apigateway.id
  domain_name = aws_apigatewayv2_domain_name.api.id
  stage       = aws_apigatewayv2_stage.api_stage.name
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id          = aws_apigatewayv2_api.apigateway.id
  auto_deploy     = true
  name            = "default"
  tags            = {
    name          = "${local.prefix}-apigateway-logs"
    Environment   = var.environment
    Client        = var.client
    Region        = var.region
    Application   = local.application
  }
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_log_group.arn
    format          = "$context.identity.sourceIp,$context.requestTime,$context.httpMethod,$context.routeKey,$context.protocol,$context.status,$context.responseLength,$context.requestId"
  }
}

resource "aws_cloudwatch_log_group" "api_log_group" {
  name = "${local.prefix}-api-log-group"

  tags = {
    name          = "${local.prefix}-apigateway-log-group"
    Environment   = var.environment
    Client        = var.client
    Region        = var.region
    Application   = local.application
  }
}
