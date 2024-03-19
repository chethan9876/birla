output "hosted_zone_id" {
  description = "Route53 Hosted zone id"
  value = aws_route53_zone.hosted_zone.id
}

output "hosted_zone_name" {
  description = "Hosted zone name"
  value = aws_route53_zone.hosted_zone.name
}

output "hosted_zone_arn" {
  description = "Hosted zone arn"
  value = aws_route53_zone.hosted_zone.arn
}