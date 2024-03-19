output "zookeeper_connect_string" {
  description = "zookeeper connection host:port pairs"
  value = aws_msk_cluster.msk_cluster.zookeeper_connect_string
}

output "bootstrap_brokers_tls" {
  description = "bootstrap server TLS connection host:port pairs"
  value       = aws_msk_cluster.msk_cluster.bootstrap_brokers_tls
}

output "msk_security_group_id" {
  description = "The MSK Security group id created."
  value = aws_security_group.msk_security_group.id
}