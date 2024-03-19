locals {
  application = "alcyon-backoffice"
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  username = lower(trimspace(var.username))
  prefix = "${local.environment}-${local.client}-${local.application}-${local.username}-user"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_user_policy" "iam_user_policy" {
  name = "${local.prefix}-policy"
  user = aws_iam_user.iam_user.name
  policy = var.policy_json
}

resource "aws_iam_user" "iam_user" {
  name = local.prefix

  tags = {
    Name = local.prefix
    Environment = local.environment
    Region = var.region
    Client = local.client
  }
}

resource "aws_iam_access_key" "api_gateway_user_access_key" {
  user = aws_iam_user.iam_user.name
}

module "secret_key" {
  source = "../../secrets_manager/predefined_secret"
  secret_prefix = "${local.prefix}-key"
  secret = aws_iam_access_key.api_gateway_user_access_key.secret
}