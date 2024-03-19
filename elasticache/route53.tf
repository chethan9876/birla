resource "aws_route53_record" "rds_route53_record" {
  provider = aws.route53
  zone_id = var.hosted_zone_id
  name = "${local.elasticache_cluster_name}.${var.hosted_zone_name}"
  type = "CNAME"
  ttl = "60"
  records = [
    aws_elasticache_replication_group.elasticache_cluster_replication_group.primary_endpoint_address
  ]
}