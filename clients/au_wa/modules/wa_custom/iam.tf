module "dot_role" {
  source = "../../../../templates/iam/role"
  client = local.client
  application = local.application
  environment = local.environment
  region = local.region
  role = "dot-rest-api-gateway"
  trust_json = data.aws_iam_policy_document.dot_assume_policy.json
  policy_json = data.aws_iam_policy_document.dot_policy.json
}

data "aws_iam_policy_document" "dot_policy" {
  statement {
    actions = ["execute-api:Invoke"]
    resources = ["${module.rest_api.rest_api_execution_arn}/*/*/*"]
  }
}

data "aws_iam_policy_document" "dot_assume_policy" {
  statement {
    principals {
      identifiers = ["transfer.amazonaws.com"]
      type = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
  statement {
    principals {
      identifiers = var.assumer_roles
      type = "AWS"
    }
    actions = ["sts:AssumeRole"]
    condition {
      test = "StringEquals"
      values = [var.dotApiExternalID]
      variable = "sts:ExternalId"
    }
  }
}