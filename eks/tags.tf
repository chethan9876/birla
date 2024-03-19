resource "aws_ec2_tag" "cluster_vpc_tag" {
  resource_id = var.vpc_id
  key         = "kubernetes.io/cluster/${local.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "cluster_private_subnet_tag" {
  for_each    = toset(compact(concat(var.subnet_ids, var.approach_node_subnet_ids, var.secure_node_subnet_ids)))
  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

resource "aws_ec2_tag" "cluster_private_subnet_cluster_tag" {
  for_each    = toset(compact(concat(var.subnet_ids, var.approach_node_subnet_ids, var.secure_node_subnet_ids)))
  resource_id = each.value
  key         = "kubernetes.io/cluster/${local.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "cluster_public_subnet_tag" {
  for_each    = toset(var.dmz_ids)
  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "cluster_public_subnet_cluster_tag" {
  for_each    = toset(var.dmz_ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${local.cluster_name}"
  value       = "shared"
}