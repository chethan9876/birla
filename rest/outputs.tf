output "lb_arn" {
  description = "arn of the load balancer"
  value = module.rest_api_nlb.listener_arn
}

output "vpce_network_interface_ip_1" {
  value = module.vpce.network_interface_ip_1
}
output "vpce_network_interface_ip_2" {
  value = module.vpce.network_interface_ip_2
}
output "vpce_network_interface_ip_3" {
  value = module.vpce.network_interface_ip_3
}

output "rest_api_execution_arn" {
  value = aws_api_gateway_rest_api.rest_api.execution_arn
}

output "rest_api_id" {
  value = aws_api_gateway_rest_api.rest_api.id
}

output "rest_api_root_resource_id" {
  value = aws_api_gateway_rest_api.rest_api.root_resource_id
}

output "vpc_link_id" {
  value = aws_api_gateway_vpc_link.rest_api_vpc_link.id
}