data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "api_gateway_user_policy" {
  version = "2012-10-17"

  statement {
    actions = [
      "execute-api:Invoke"]
    effect = "Allow"
    resources = [
      "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.apigateway.id}/*/*/*"]
    condition {
      test = "IpAddress"
      values = var.whitelist_ips
      variable = "aws:SourceIp"
    }
  }
}

module "api_iam_user" {
  source = "../../iam/user"
  application = local.application
  client = var.client
  environment = var.environment
  region = var.region
  policy_json = data.aws_iam_policy_document.api_gateway_user_policy.json
  username = "api-gateway"
}