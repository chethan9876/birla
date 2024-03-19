module "s3_kms_key" {
  source = "../../templates/kms"
  application = local.application
  client = local.client
  environment = var.environment
  name = "s3"
}

module "media_s3_bucket" {
  source = "../../templates/s3"
  application = local.application
  client = local.client
  environment = var.environment
  aws_kms_s3_key_arn = module.s3_kms_key.kms_key_arn
  name = "media"
  s3_log_bucket = var.s3_log_bucket
  cors_rules = [{
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = [var.cors_domain]
    expose_headers = ["ETag"]
    max_age_seconds = 3000
  }]
}

module "template_s3_bucket" {
  source = "../../templates/s3"
  application = local.application
  client = local.client
  environment = var.environment
  aws_kms_s3_key_arn = module.s3_kms_key.kms_key_arn
  name = "template"
  s3_log_bucket = var.s3_log_bucket
}
