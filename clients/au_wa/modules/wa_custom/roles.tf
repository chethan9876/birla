resource "aws_iam_role" "api_gateway_sqs" {
  name               = "${local.prefix}-apigateway-role"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume_role_policy_document.json
  tags = {
    name = "${local.prefix}-apigateway-role"
    client = var.client
    environment = var.environment
  }
}

data "aws_iam_policy_document" "api_gateway_assume_role_policy_document" {
  version = "2012-10-17"
  statement {
    actions = [
      "sts:AssumeRole"]
    effect = "Allow"
    principals {
      identifiers = [
        "apigateway.amazonaws.com"]
      type = "Service"
    }
  }
}  
data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = [
      module.sqs_kms_key.kms_key_arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      module.payment_received_events.sqs_queue_arn]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "${local.prefix}-api-gateway-policy"
  policy      = data.aws_iam_policy_document.policy.json
  tags = {
    name = "${local.prefix}-api-gateway-policy"
    client = var.client
    environment = var.environment
  }
}

  
resource "aws_iam_role_policy_attachment" "api_gateway_role_policy_attachment" {
  policy_arn = aws_iam_policy.policy.arn
  role = aws_iam_role.api_gateway_sqs.name
}