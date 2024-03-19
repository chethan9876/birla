resource "aws_security_group" "itservice_security_group" {
  name        = ("${var.environment}-${var.client}-itservice-sg")
  description = "Security group for IT Services"
  vpc_id      = var.vpc_id

   dynamic "ingress" {
    for_each = var.itservice_securitygroup_ingress_ports
    content {
      protocol          = lookup(ingress.value, "protocol", null)
      from_port         = lookup(ingress.value, "from_port", null)
      to_port           = lookup(ingress.value, "to_port", null)
      cidr_blocks       = lookup(ingress.value, "cidr_blocks", null)
      security_groups   = lookup(ingress.value, "security_groups", null)
      description       = lookup(ingress.value, "description", null)
    }
  }
  dynamic "egress"  {
    for_each = var.itservice_securitygroup_egress_ports
    content {
      protocol          = lookup(egress.value, "protocol", null)
      from_port         = lookup(egress.value, "from_port", null)
      to_port           = lookup(egress.value, "to_port", null)
      cidr_blocks       = lookup(egress.value, "cidr_blocks", null)
      security_groups   = lookup(egress.value, "security_groups", null)
      description       = lookup(egress.value, "description", null)
    }
}
  tags = {
    Name = ("${var.environment}-${var.client}-itservice-sg")
    Client = var.client
    Environment = var.environment
  }
  }

