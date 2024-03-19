resource "aws_eks_node_group" "cluster-node-group" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_group_name = "${local.prefix}-node-group"
  node_role_arn = aws_iam_role.cluster_worker_node_role.arn
  instance_types = [
    var.cluster_worker_node_instance_type]
  version = var.eks_version

  remote_access {
    ec2_ssh_key = var.cluster_worker_node_ssh_key
    source_security_group_ids = [
      aws_security_group.cluster_admin_security_group.id]
  }

  subnet_ids = var.subnet_ids

  scaling_config {
    desired_size = var.cluster_worker_node_autoscaling_desired_size
    max_size = var.cluster_worker_node_autoscaling_max_size
    min_size = var.cluster_worker_node_autoscaling_min_size
  }

  labels = {
    Name = "${local.prefix}-node"
  }

  tags = {
    Name = "${local.prefix}-node"
    Client = var.client
    Environment = var.environment
  }

  disk_size = var.cluster_worker_node_disk_size
  force_update_version = "true"

  lifecycle {
    ignore_changes = [ scaling_config[0].desired_size ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_worker_node_role_cluster_policy_attachment,
    aws_iam_role_policy_attachment.cluster_worker_node_role_cluster_cni_policy_attachment
  ]
}

resource "aws_eks_node_group" "cluster-secure-node-group" {
  count = length(var.secure_node_subnet_ids) > 0 ? 1 : 0
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_group_name = "${local.prefix}-secure-node-group"
  node_role_arn = aws_iam_role.cluster_worker_node_role.arn
  instance_types = [
    var.cluster_worker_node_instance_type]
  version = var.eks_version

  remote_access {
    ec2_ssh_key = var.cluster_worker_node_ssh_key
    source_security_group_ids = [
      aws_security_group.cluster_admin_security_group.id]
  }

  subnet_ids = var.secure_node_subnet_ids

  scaling_config {
    desired_size = 1
    max_size = 1
    min_size = 1
  }

  taint  {
    key = "connectivity"
    value = "dmv"
    effect = "NO_SCHEDULE"
  }

  labels = {
    Name = "${local.prefix}-secure-node"
    connectivity = "dmv"
  }

  tags = {
    Name = "${local.prefix}-secure-node"
    Client = var.client
    Environment = var.environment
  }

  disk_size = var.cluster_worker_node_disk_size
  force_update_version = "true"

  lifecycle {
    ignore_changes = [ scaling_config[0].desired_size ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_worker_node_role_cluster_policy_attachment,
    aws_iam_role_policy_attachment.cluster_worker_node_role_cluster_cni_policy_attachment
  ]
}

resource "aws_eks_node_group" "cluster-approach-node-group" {
  count = length(var.approach_node_subnet_ids) > 0 ? 1 : 0
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_group_name = "${local.prefix}-approach-node-group"
  node_role_arn = aws_iam_role.cluster_worker_node_role.arn
  instance_types = [
    var.cluster_worker_node_instance_type]
  version = var.eks_version

  remote_access {
    ec2_ssh_key = var.cluster_worker_node_ssh_key
    source_security_group_ids = [
      aws_security_group.cluster_admin_security_group.id]
  }

  subnet_ids = var.approach_node_subnet_ids

  scaling_config {
    desired_size = 1
    max_size = 1
    min_size = 1
  }

  taint  {
    key = "connectivity"
    value = "approach"
    effect = "NO_SCHEDULE"
  }

  labels = {
    Name = "${local.prefix}-approach-node"
    connectivity = "approach"
  }

  tags = {
    Name = "${local.prefix}-approach-node"
    Client = var.client
    Environment = var.environment
  }

  disk_size = var.cluster_worker_node_disk_size
  force_update_version = "true"

  lifecycle {
    ignore_changes = [ scaling_config[0].desired_size ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_worker_node_role_cluster_policy_attachment,
    aws_iam_role_policy_attachment.cluster_worker_node_role_cluster_cni_policy_attachment
  ]
}