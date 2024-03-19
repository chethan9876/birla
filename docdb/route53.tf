resource "aws_route53_record" "docdb_domain" {
  provider = aws.route53
  zone_id = var.hosted_zone_id
  name = "${local.docdb_cluster_name}.${var.hosted_zone_name}"
  type = "CNAME"
  ttl = "60"
  records = [
    aws_docdb_cluster.cluster.endpoint]
}