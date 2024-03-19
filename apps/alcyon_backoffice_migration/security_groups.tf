resource "aws_security_group_rule" "eks_cluster_to_alcyon_backoffice_docdb_ingress_security_group_rule" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = module.docdb.docdb_security_group_id
  source_security_group_id = var.eks_cluster_security_group_id
}

resource "aws_security_group_rule" "eks_cluster_to_alcyon_backoffice_elasticache_ingress_security_group_rule" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = module.elasticache.elasticache_security_group_id
  source_security_group_id = var.eks_cluster_security_group_id
}

resource "aws_security_group_rule" "admin_to_alcyon_backoffice_docdb_ingress_security_group_rule" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = module.docdb.docdb_security_group_id
  source_security_group_id = var.admin_security_group_id
}

resource "aws_security_group_rule" "admin_to_alcyon_backoffice_elasticache_ingress_security_group_rule" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = module.elasticache.elasticache_security_group_id
  source_security_group_id = var.admin_security_group_id
}

resource "aws_security_group_rule" "jumpbox_to_alcyon_backoffice_docdb_ingress_security_group_rule" {
  count                    = var.jumpbox_security_group_id == "" ? 0 : 1
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = module.docdb.docdb_security_group_id
  source_security_group_id = var.jumpbox_security_group_id
}

resource "aws_security_group_rule" "jumpbox_to_alcyon_backoffice_elasticache_ingress_security_group_rule" {
  count                    = var.jumpbox_security_group_id == "" ? 0 : 1
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = module.elasticache.elasticache_security_group_id
  source_security_group_id = var.jumpbox_security_group_id
}