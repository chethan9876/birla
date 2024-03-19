resource "aws_api_gateway_resource" "resource" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_resource_id
  path_part   = var.path
}

resource "aws_api_gateway_method" "method" {
  rest_api_id        = var.rest_api_id
  resource_id        = aws_api_gateway_resource.resource.id
  http_method        = var.http_method
  authorization      = var.authorisation
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = var.http_method

  type                    = var.integration_type
  uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${var.queue_name}"
  integration_http_method = var.http_method
  passthrough_behavior = "NEVER"
  credentials = var.role_arn

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$input.body"
  }
}

resource "aws_api_gateway_integration_response" "integration_response" {
  http_method = var.http_method
  resource_id = aws_api_gateway_resource.resource.id
  rest_api_id = var.rest_api_id
  status_code = 200
}

resource "aws_api_gateway_method_response" "method_response" {
  http_method = var.http_method
  resource_id = aws_api_gateway_resource.resource.id
  rest_api_id = var.rest_api_id
  status_code = 200
}