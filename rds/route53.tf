resource "aws_route53_record" "rds_route53_record" {
  provider = aws.route53
  zone_id = var.hosted_zone_id
  name = "${local.db_cluster_name}.${var.hosted_zone_name}"
  type = "CNAME"
  ttl = "60"
  records = [
    aws_rds_cluster.db_cluster.endpoint
  ]
}