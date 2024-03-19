data "aws_secretsmanager_secret" "domain_secret" {
  name = "${local.environment}-${local.client}-domain"
}

data "aws_secretsmanager_secret_version" "domain_secret_current" {
  secret_id = data.aws_secretsmanager_secret.domain_secret.id
}