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
  request_parameters = var.integration_type == "HTTP_PROXY" ? { "method.request.path.proxy" = true } : {}
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = var.http_method

  type                    = var.integration_type
  uri                     = var.integration_url
  integration_http_method = var.http_method

  connection_type = "VPC_LINK"
  connection_id   = var.vpc_link_id

  request_parameters = var.integration_type == "HTTP_PROXY" ?  { "integration.request.path.proxy" = "method.request.path.proxy" } : {}

  depends_on = [aws_api_gateway_method.method]
}

resource "aws_api_gateway_integration_response" "integration_response" {
  http_method = var.http_method
  resource_id = aws_api_gateway_resource.resource.id
  rest_api_id = var.rest_api_id
  status_code = 200

  depends_on = [aws_api_gateway_integration.integration]
}

resource "aws_api_gateway_method_response" "method_response" {
  http_method = var.http_method
  resource_id = aws_api_gateway_resource.resource.id
  rest_api_id = var.rest_api_id
  status_code = 200

  depends_on = [aws_api_gateway_integration_response.integration_response]
}