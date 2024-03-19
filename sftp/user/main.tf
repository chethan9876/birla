locals {
  application = lower(trimspace(var.application))
  client      = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  name        = "${local.environment}-${local.client}-${local.application}-sftp"
}

resource "aws_iam_role" "ftp_access" {
  name               = "${local.name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name   = "${local.name}-policy"
    policy = data.aws_iam_policy_document.sftp_policy.json
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "sftp_policy" {
  statement {
    effect = "Allow"
    actions = [
    var.sftp_domain == "EFS" ? "elasticfilesystem:*" : "S3:*"]
    resources = [
    var.service_arn]
  }
}

resource "aws_transfer_user" "user" {
  server_id = var.sftp_server_id
  user_name = var.user
  role      = aws_iam_role.ftp_access.arn

  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/"
    target = "/${var.service_id}${var.home_folder}"
  }
  posix_profile {
    gid            = var.posix_group_id
    uid            = var.posix_user_id
    secondary_gids = var.secondary_group_id
  }
}

resource "aws_transfer_ssh_key" "user_ssh_public_key" {
  server_id = var.sftp_server_id
  user_name = aws_transfer_user.user.user_name
  body      = tls_private_key.ssh_key.public_key_openssh
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "private_key" {
  source        = "../../secrets_manager/predefined_secret"
  secret_prefix = "${local.name}-${var.user}-private-key"
  secret        = tls_private_key.ssh_key.private_key_pem
}