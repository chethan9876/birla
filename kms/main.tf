locals {
  application = lower(trimspace(var.application))
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  name = lower(trimspace(var.name))
  key_name = "${local.environment}-${local.client}-${local.application}-${local.name}-kms"
}

resource "aws_kms_key" "kms_key" {
  description = "${local.key_name} encryption key"
  enable_key_rotation = true
  tags = {
    Name = local.key_name
    Client = local.client
    Environment = local.environment
    Application = local.application
  }
  policy = var.key_policy
}

resource "aws_kms_alias" "kms_key_alias" {
  name = "alias/${local.key_name}"
  target_key_id = aws_kms_key.kms_key.key_id
}