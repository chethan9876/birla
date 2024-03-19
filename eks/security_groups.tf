
resource "aws_security_group" "cluster_security_group" {
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

resource "aws_security_group_rule" "cluster_efs_security_group_rule" {
  security_group_id = var.efs_file_system_security_group_id
  source_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  type = "ingress"
  from_port = 2049
  to_port = 2049
  protocol = "tcp"
}

resource "aws_security_group" "cluster_admin_security_group" {
  name = "${local.prefix}-admin-sg"
  description = "Security group for ${local.prefix} admin"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "${local.prefix}-admin-sg"
    Client = var.client
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "cluster_admin_efs_security_group_rule" {
  security_group_id = var.efs_file_system_security_group_id
  source_security_group_id = aws_security_group.cluster_admin_security_group.id
  type = "ingress"
  from_port = 2049
  to_port = 2049
  protocol = "tcp"
}

resource "aws_security_group_rule" "jumpbox_ingress_security_group_rule" {
  security_group_id = aws_security_group.cluster_admin_security_group.id
  source_security_group_id = var.jumpbox_ingress_security_group_id
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
}

resource "aws_security_group_rule" "cluster_admin_workspaces_ingress_security_group_rule" {
  for_each = toset(var.workspace_ip_ranges)
  security_group_id = aws_security_group.cluster_admin_security_group.id
  cidr_blocks = [each.value]
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
}

resource "aws_security_group_rule" "cluster_admin_to_cluster_ingress_security_group_rule" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.cluster_security_group.id
  source_security_group_id = aws_security_group.cluster_admin_security_group.id
}
