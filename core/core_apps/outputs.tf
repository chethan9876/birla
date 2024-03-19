output "eks_cluster_security_group_id" {
  description = "The EKS cluster security group id."
  value = module.eks.cluster_security_group_id
}

output "eks_cluster_worker_node_role_name" {
  description = "The EKS cluster worker node role name."
  value = module.eks.cluster_worker_node_role_name
}


output "eks_cluster_admin_security_group_id" {
  description = "The EKS cluster admin security group id."
  value = module.eks.cluster_admin_security_group_id
}

output "hosted_zone_name" {
  description = "Route53 hosted zone name"
  value = module.hosted_zone.hosted_zone_name
}

output "hosted_zone_id" {
  description = "Route53 hosted zone id"
  value = module.hosted_zone.hosted_zone_id
}

output "jumpbox_security_group_id" {
  description = "Jumpbox security group id"
  value = aws_security_group.jumpbox_security_group.id
}

output "certificate_arn" {
  description = "certificate arn"
  value = module.acm.certificate_arn
}

output "efs_arn" {
  description = "arn of the efs fileshare"
  value = module.efs.efs_arn
}

output "efs_id" {
  description = "ID of the efs fileshare"
  value = module.efs.efs_id
}

output "es_snapshot_s3_bucket" {
  value = module.es_snapshot_s3_bucket.s3_bucket_arn
}