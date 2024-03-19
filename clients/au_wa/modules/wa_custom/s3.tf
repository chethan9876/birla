module "s3_kms_key" {
  source = "../../../../templates/kms"
  application = local.application
  client = local.client
  environment = var.environment
  name = "au-wa-s3"
}

module "original_evidence" {
  source = "../../../../templates/s3"
  name = "original-evidence"
  application = local.application
  aws_kms_s3_key_arn = module.s3_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  s3_log_bucket = var.s3_log_bucket_name
}