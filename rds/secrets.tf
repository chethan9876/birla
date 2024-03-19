
module "master_password" {
  source = "../secrets_manager/secret"
  secret_prefix = "${local.environment}-${local.client}-${local.application}-rds"
}

data "aws_secretsmanager_secret" "rds_secret" {
  name = module.master_password.secret_name
}

data "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = data.aws_secretsmanager_secret.rds_secret.id
}