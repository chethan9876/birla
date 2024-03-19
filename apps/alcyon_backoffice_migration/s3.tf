module "preview_media_s3_bucket" {
  source = "../../templates/s3"
  application = local.application
  client = local.client
  environment = var.environment
  aws_kms_s3_key_arn = module.s3_kms_key.kms_key_arn
  name = "preview-media"
  s3_log_bucket = var.s3_log_bucket
}

module "legacy_media_s3_bucket" {
  source = "../../templates/s3"
  application = local.application
  client = local.client
  environment = var.environment
  aws_kms_s3_key_arn = module.s3_kms_key.kms_key_arn
  name = "legacy-media"
  s3_log_bucket = var.s3_log_bucket
}

data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "legacy_media_user_policy" {
  version = "2012-10-17"

  statement {
    actions = [
      "s3:Put*",
      "s3:ListBucket",
      "s3:Get*",
      "s3:DeleteObject"]
    effect = "Allow"
    resources = [
      "${module.legacy_media_s3_bucket.s3_bucket_arn}/*", module.legacy_media_s3_bucket.s3_bucket_arn]
  }
  statement {
    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:Decrypt"]
    effect = "Allow"
    resources = [
      module.s3_kms_key.kms_key_arn]
  }
}

module "legacy_media_iam_user" {
  source = "../../templates/iam/user"
  application = local.application
  client = var.client
  environment = var.environment
  region = var.region
  policy_json = data.aws_iam_policy_document.legacy_media_user_policy.json
  username = "legacy-media"
}