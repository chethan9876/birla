data "aws_iam_policy_document" "s3_kms_key_policy" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      type = "AWS"
    }
    actions = ["kms:*"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type = "Service"
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test = "StringEquals"
      values = [data.aws_caller_identity.current.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test = "ArnLike"
      values = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"]
      variable = "aws:SourceArn"
    }
  }
}

module "s3_kms_key" {
  source = "../../templates/kms"
  application = local.application
  client = local.client
  environment = var.environment
  name = "s3"
  key_policy = data.aws_iam_policy_document.s3_kms_key_policy.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "sns_kms_key_policy" {
  statement {
    principals {
      identifiers = [
        "${var.iam_arn_prefix}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
      type = "AWS"
    }
    actions = [
      "kms:*",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    principals {
      identifiers = [
        "cloudwatch.amazonaws.com"
      ]
      type = "Service"
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]
    resources = [
      "*",
    ]
  }
}

module "sns_kms_key" {
  source = "../../templates/kms"
  application = local.application
  client = local.client
  environment = var.environment
  name = "sns"
  key_policy = data.aws_iam_policy_document.sns_kms_key_policy.json
}
