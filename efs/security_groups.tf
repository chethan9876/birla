resource "aws_security_group" "efs_security_group" {
  name = "${local.efs_name}-sg"
  description = "${local.efs_name}-sg"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "${local.efs_name}-sg"
    environment = local.environment
    application = local.application
    Client = var.client
  }
}