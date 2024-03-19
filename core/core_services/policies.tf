data "aws_iam_policy_document" "sns_assume_role_policy" {
  version = "2012-10-17"
  statement {
    actions = [
      "sts:AssumeRole"]
    effect = "Allow"
    principals {
      identifiers = [
        "sns.amazonaws.com"]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "sns_feedback_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy"
    ]
    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "vpc_flow_log_policy" {
  statement  {
    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:DeleteLogDelivery"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "s3_flow_log_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.prefix}-vpc-flow-log-s3/*"]
    condition {
      test = "StringEquals"
      variable = "aws:SourceAccount"
      values = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test = "StringEquals"
      variable = "s3:x-amz-acl"
      values = ["bucket-owner-full-control"]
    }
    condition {
      test = "ArnLike"
      variable = "aws:SourceArn"
      values = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${local.prefix}-vpc-flow-log-s3"]
    condition {
      test = "StringEquals"
      variable = "aws:SourceAccount"
      values = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test = "ArnLike"
      variable = "aws:SourceArn"
      values = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}


data "aws_iam_policy_document" "cloud_trail_s3_policy" {
  statement  {
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type = "Service"
    }
    actions = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloud_trail_s3.arn]
  }
  statement  {
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type = "Service"
    }
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloud_trail_s3.arn}/cloudtrail/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test = "StringEquals"
      values = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
    condition {
      test = "StringEquals"
      values = ["${var.iam_arn_prefix}:cloudtrail:${var.region}:${data.aws_caller_identity.current.account_id}:trail/${local.environment}-${local.client}-cloudtrail"]
      variable = "aws:SourceArn"
    }
  }
}