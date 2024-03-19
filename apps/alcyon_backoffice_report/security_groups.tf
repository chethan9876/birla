resource "aws_security_group_rule" "eks_cluster_to_alcyon_backoffice_report_rds_ingress_security_group_rule" {
  type = "ingress"
  from_port = 5432
  to_port = 5432
  protocol = "tcp"
  security_group_id = module.rds_db.rds_security_group_id
  source_security_group_id = var.eks_cluster_security_group_id
}

resource "aws_security_group_rule" "eks_cluster_admin_to_alcyon_backoffice_rds_ingress_security_group_rule" {
  type = "ingress"
  from_port = 5432
  to_port = 5432
  protocol = "tcp"
  security_group_id = module.rds_db.rds_security_group_id
  source_security_group_id = var.admin_security_group_id
}

resource "aws_security_group_rule" "jumpbox_to_alcyon_backoffice_rds_ingress_security_group_rule" {
  count = var.jumpbox_security_group_id == "" ? 0 : 1
  type = "ingress"
  from_port = 5432
  to_port = 5432
  protocol = "tcp"
  security_group_id = module.rds_db.rds_security_group_id
  source_security_group_id = var.jumpbox_security_group_id
}