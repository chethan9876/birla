output "es_endpoint" {
  description = "The Elasticsearch endpoint"
  value = aws_elasticsearch_domain.es_domain.endpoint
}