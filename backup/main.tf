locals {
  application = "backup"
  client      = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  prefix      = "${local.environment}-${local.client}-${local.application}"
}

//provider "aws" {
//  profile = var.profile
//  region  = var.region
//  ignore_tags {
//    key_prefixes = ["kubernetes.io/"]
//  }
//}

resource "aws_backup_vault" "backup_vault" {
  name        = ("${var.environment}-${var.client}-backup_vault")

  tags = {
    Name = ("${var.environment}-${var.client}-backup_vault")
    Environment = local.environment
    Client = local.client
    Application = local.application
   
  }
}


resource "aws_backup_plan" "backup_plan" {
  name = ("${var.environment}-${var.client}-backup_plan")

  rule {
    rule_name         = "Daily_backup_rule"
    target_vault_name = aws_backup_vault.backup_vault.id
    schedule          = "cron(0 12 * * ? *)"
  }

   tags = {
     Name = "${local.prefix}-backup_plan"
     Environment = local.environment
     Client = local.client
     Application = local.application
  }
}

resource "aws_backup_selection" "backup_selection" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = ("${var.environment}-${var.client}-backup_selection")
  plan_id      = aws_backup_plan.backup_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "standardbackup"
    value = "enabled"
  }
}


