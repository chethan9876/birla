resource "aws_iam_role" "cluster_master_role" {
  name = "${local.prefix}-master-role-iam"
  assume_role_policy = data.aws_iam_policy_document.cluster_master_role_policy.json

  tags = {
    Name = "${local.prefix}-air"
    Client = var.client
    Environment = var.environment
  }
}
resource "aws_iam_role" "eks_loadbalancer_role" {
  name = "${local.prefix}-eksloadbalancer-role-iam"
  #assume_role_policy = data.aws_iam_policy_document.aws_loadbalancer_controller_policy.json
  assume_role_policy = data.aws_iam_policy_document.aws_loadbalancer_controller_assume_policy.json

  tags = {
    Name = "${local.prefix}-eks-loadbalancer-role"
    Client = var.client
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "eks_load_balancer_policy_attachment" {
  policy_arn = aws_iam_policy.aws_loadbalancer_controller_policy.arn
  role = aws_iam_role.eks_loadbalancer_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_master_role_cluster_policy_attachment" {
  policy_arn = "${var.iam_arn_prefix}:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.cluster_master_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_master_role_cluster_service_policy_attachment" {
  policy_arn = "${var.iam_arn_prefix}:iam::aws:policy/AmazonEKSServicePolicy"
  role = aws_iam_role.cluster_master_role.name
}

resource "aws_iam_role" "cluster_autoscaler_role" {
  name = "${local.prefix}-autoscaler-role-iam"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role_policy.json

  tags = {
    Name = "${local.prefix}-air"
    Client = var.client
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_role_policy_attachment" {
  role = aws_iam_role.cluster_autoscaler_role.name
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
}

resource "aws_iam_role" "cluster_worker_node_role" {
  name = "${local.prefix}-worker-node-role-iam"
  assume_role_policy = data.aws_iam_policy_document.cluster_worker_node_assume_role_policy.json

  tags = {
    Name = "${local.prefix}-air"
    Client = var.client
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "cluster_worker_node_role_cluster_policy_attachment" {
  policy_arn = "${var.iam_arn_prefix}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.cluster_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_worker_node_role_cluster_cni_policy_attachment" {
  policy_arn = "${var.iam_arn_prefix}:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.cluster_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_worker_node_role_cluster_container_registry_readonly_policy_attachment" {
  policy_arn = "${var.iam_arn_prefix}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.cluster_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_worker_node_base_policy_attachment" {
  role = aws_iam_role.cluster_worker_node_role.name
  policy_arn = aws_iam_policy.cluster_worker_node_base_policy.arn
}


resource "aws_iam_role" "aws_ebs_csi_driver_role" {
  name = "${local.prefix}-aws-ebs-csi-driver-role"
  assume_role_policy = data.aws_iam_policy_document.aws-ebs-csi-driver-trust-policy.json

  tags = {
    Name = "${local.prefix}-aws-ebs-csi-driver-role"
    Client = var.client
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "aws_ebs_csi_driver_trust_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role = aws_iam_role.aws_ebs_csi_driver_role.name
}
