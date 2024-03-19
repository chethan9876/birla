locals {
  application = "alcyon-backoffice"
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  role = lower(trimspace(var.role))
  prefix = "${local.environment}-${local.client}-${local.application}-${local.role}"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "role" {
  name = "${local.prefix}-iam-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = var.trust_json

  tags = {
    Name = "${local.prefix}-iam-role"
    Client = var.client
    Environment = var.environment
    Application = var.application
  }
}

resource "aws_iam_role_policy" "policy" {
  name = "${local.prefix}-iam-policy"
  role = aws_iam_role.role.id
  policy = var.policy_json
}