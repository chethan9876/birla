output "cluster_security_group_id" {
  description = "The EKS cluster security group id."
  value = aws_eks_cluster.eks_cluster.vpc_config.0.cluster_security_group_id
}

output "cluster_worker_node_role_name" {
  description = "The EKS cluster worker node role name."
  value = aws_iam_role.cluster_worker_node_role.name
}

output "cluster_admin_security_group_id" {
  description = "The EKS cluster admin security group id."
  value = aws_security_group.cluster_admin_security_group.id
}

