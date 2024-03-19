resource "aws_route53_record" "efs_route53_record" {
  provider = aws.route53
  zone_id = var.hosted_zone_id
  name = "${local.efs_name}.${var.hosted_zone_name}"
  type = "CNAME"
  ttl = "60"
  records = [
    aws_efs_file_system.efs.dns_name
  ]
}