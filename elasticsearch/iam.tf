resource "aws_iam_role" "es_snapshot_lambda_role" {
  name = "${local.es_domain_name}-snapshot-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.es_snapshot_lambda_assume_role_policy_document.json

  tags = {
    Name = "${local.es_domain_name}-es-snapshot-lambda-role"
    Client = var.client
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "es_snapshot_lambda_assume_role_policy_document" {
  version = "2012-10-17"
  statement {
    actions = [
      "sts:AssumeRole"]
    effect = "Allow"
    principals {
      identifiers = [
        "lambda.amazonaws.com",
        "es.amazonaws.com"]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "es_snapshot_lambda_role_policy_document" {
  version = "2012-10-17"

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot",
      "ec2:CreateTags",
      "ec2:ModifySnapshotAttribute",
      "ec2:ResetSnapshotAttribute",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "iam:PassRole",
      "es:*"]
    effect = "Allow"
    resources = [
      "*"]
  }
}

resource "aws_iam_role_policy" "es_snapshot_lambda_role_policy" {
  name = "${local.es_domain_name}-snapshot-lambda-role-policy"
  role = aws_iam_role.es_snapshot_lambda_role.id
  policy = data.aws_iam_policy_document.es_snapshot_lambda_role_policy_document.json
}

data "aws_iam_policy_document" "es_snapshot_role_policy_document" {
  version = "2012-10-17"
  statement {
    actions = [
      "s3:ListBucket"]
    effect = "Allow"
    resources = [
      "${var.iam_arn_prefix}:s3:::${var.es_snapshot_s3_bucket}"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"]
    effect = "Allow"
    resources = [
      "${var.iam_arn_prefix}:s3:::${var.es_snapshot_s3_bucket}/*"]
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"]
    effect = "Allow"
    resources = [
      var.s3_kms_key_arn]
  }

  statement {
    actions = ["sns:Publish"]
    effect = "Allow"
    resources = [var.sns_topic]
  }
}


resource "aws_iam_role_policy" "es_snapshot_role_policy" {
  role = aws_iam_role.es_snapshot_lambda_role.id
  policy = data.aws_iam_policy_document.es_snapshot_role_policy_document.json
}