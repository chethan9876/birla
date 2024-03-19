resource "aws_security_group" "crowdstrike_sg" {
  name = "${local.prefix}-crowdstrike-sg"
  vpc_id = var.vpc_id
  description = "${local.prefix} security group"

  tags = {
    Name = "${local.prefix}-crowdstrike-sg"
    Client = var.client
    Environment = var.environment
  }

  egress {
    from_port = 443
    protocol = "TCP"
    to_port = 443
    cidr_blocks = [
      "35.162.224.228/32",
      "52.10.219.156/32",
      "100.20.76.137/32",
      "34.210.186.129/32",
      "35.162.239.174/32",
      "34.209.79.111/32"]

  }
}