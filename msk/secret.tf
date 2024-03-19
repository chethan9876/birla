resource "aws_secretsmanager_secret" "msk_secret_password" {
  name = "AmazonMSK_${local.cluster_name}-password"
  kms_key_id = var.msk_kms_key_arn

  tags = {
    Name = "AmazonMSK_${local.cluster_name}-password"
    Client = var.client
    Application = var.application
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "msk_secret_password_version" {
  secret_id     = aws_secretsmanager_secret.msk_secret_password.id
  secret_string = <<EOF
   {
    "username": "alcyon",
    "password": "${random_password.msk_pass.result}"
    }
  EOF
}

resource "random_password" "msk_pass"{
  length           = 16
  special          = true
  override_special = "_!%^"
}