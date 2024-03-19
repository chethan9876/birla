resource "aws_security_group" "msk_security_group" {
  name = "${local.cluster_name}-sg"
  vpc_id = var.vpc_id
  description = "${local.cluster_name} security group"

  tags = {
    Name = "${local.cluster_name}-sg"
    Client = var.client
    Environment = var.environment
  }
}

