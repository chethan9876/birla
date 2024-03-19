output "route53_endpoint_outbound" {
  value = aws_route53_resolver_endpoint.route53_resolver_endpoint_outbound.id
}