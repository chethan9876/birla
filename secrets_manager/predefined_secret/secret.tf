resource "aws_secretsmanager_secret" "password" {
  name_prefix = "${var.secret_prefix}-password-"

  tags = {
    Name = "${var.secret_prefix}-password"
//    Application = var.application
//    Client = var.client
//    Environment = var.environment

  }
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id = aws_secretsmanager_secret.password.id
  secret_string = var.secret
}