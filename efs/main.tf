locals {
  application = lower(trimspace(var.application))
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  efs_name = "${local.environment}-${local.client}-${local.application}-efs"
}

provider aws {
  alias = "route53"
  profile = var.client == "us-govcloud" ? "us-govcloud-parent" : var.client
  region = "us-east-1"
}

resource "aws_efs_file_system" "efs" {
  creation_token = local.efs_name
  encrypted = "true"
  kms_key_id = var.kms_key_id
  throughput_mode = "provisioned"
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps

  tags = {
    environment = local.environment
    Name = local.efs_name
    application = local.application
    Client = local.client
  }

  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }
}

resource "aws_efs_backup_policy" "efs_backup_policy" {
  file_system_id = aws_efs_file_system.efs.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  for_each = toset(var.mount_targets)
  file_system_id = aws_efs_file_system.efs.id
  subnet_id = each.value
  security_groups = [aws_security_group.efs_security_group.id]
}
