locals {
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  pega_layer = lower(trimspace(var.pega_layer))
  cluster_name = "${local.environment}-${local.client}-eks"
  prefix = "${local.cluster_name}-cluster"
}

provider aws {
  profile = var.client
  region = var.region
}

provider aws {
  alias = "route53"
  profile = var.client == "us-govcloud" ? "us-govcloud-parent" : var.client
  region = "us-east-1"
}

resource "aws_eks_cluster" "eks_cluster" {
  name = local.cluster_name
  role_arn = aws_iam_role.cluster_master_role.arn
  version = var.eks_version

  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [
      aws_security_group.cluster_security_group.id]
    endpoint_private_access = true
    endpoint_public_access = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_master_role_cluster_policy_attachment,
    aws_iam_role_policy_attachment.cluster_master_role_cluster_service_policy_attachment]

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator"]

  tags = {
    Name = local.cluster_name
    Environment = var.environment
    Client = local.client
  }
}