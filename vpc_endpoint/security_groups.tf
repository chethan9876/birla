resource "aws_security_group" "interface_endpoint_security_group" {
  count = var.endpoint_type == "Interface" ? 1 : 0
  name = "${local.prefix}-sg"
  description = "Security group for ${local.prefix}"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "${local.prefix}-sg"
    Client = var.client
    Environment = var.environment
   }
}

resource "aws_security_group_rule" "interface_endpoint_ingress_security_group_rule" {
  count = length(aws_security_group.interface_endpoint_security_group) > 0 ? 1 : 0
  security_group_id = aws_security_group.interface_endpoint_security_group[0].id
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"]
}