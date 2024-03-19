module "elasticache_kms_key" {
  source = "../../templates/kms"
  application = local.application
  client = local.client
  environment = var.environment
  name = "elasticache"
}

module "docdb_kms_key" {
  source = "../../templates/kms"
  application = local.application
  client = local.client
  environment = var.environment
  name = "docdb"
}

module "s3_kms_key" {
  source = "../../templates/kms"
  application = local.application
  client = local.client
  environment = var.environment
  name = "s3"
}