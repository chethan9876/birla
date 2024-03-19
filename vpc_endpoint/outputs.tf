output "vpc_endpoint_security_group_id" {
  description = "The vpc endpoint security group id created."
  value = length(aws_security_group.interface_endpoint_security_group) > 0 ? aws_security_group.interface_endpoint_security_group[0].id : null
}

output "network_interface_ip_1" {
  description = "IDs of the network interfaces"
  value = length(data.aws_network_interface.network_interfaces_0) == 1 ? data.aws_network_interface.network_interfaces_0[0].private_ip : ""
}

output "network_interface_ip_2" {
  description = "IDs of the network interfaces"
  value = length(data.aws_network_interface.network_interfaces_1) == 1 ? data.aws_network_interface.network_interfaces_1[0].private_ip : ""
}

output "network_interface_ip_3" {
  description = "IDs of the network interfaces"
  value = length(data.aws_network_interface.network_interfaces_2) == 1 ? data.aws_network_interface.network_interfaces_2[0].private_ip : ""
}

output "vpce_id" {
  description = "IDs of the VPC endpoint"
  value = aws_vpc_endpoint.vpc_endpoint.id
}