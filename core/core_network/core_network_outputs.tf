output "vpc_id" {
  value = aws_vpc.main.id
}

output "dmz_subnet_ids" {
  value = values(aws_subnet.subnets_dmz)[*].id
}
output "internal_subnet_ids" {
  value = values(aws_subnet.subnets_internal)[*].id
}
output "internal_subnet_cidr_blocks" {
  value = values(aws_subnet.subnets_internal)[*].cidr_block
}
output "database_subnet_ids" {
  value = values(aws_subnet.subnets_database)[*].id
}
output "approach_subnet_ids" {
  value = values(aws_subnet.subnets_approach)[*].id
}
output "secure_subnet_ids" {
  value = values(aws_subnet.subnets_secure)[*].id
}
output "workspaces_subnet_ids" {
  value = values(aws_subnet.subnets_workspaces)[*].id
}
output "workspaces_subnet_cidr_blocks" {
  value = values(aws_subnet.subnets_workspaces)[*].cidr_block
}

output "dmz_route_table_id" {
  value = aws_route_table.route_dmz.id
}
output "internal_route_table_id" {
  value = aws_route_table.route_internal.id
}
output "database_route_table_id" {
  value = aws_route_table.route_database.id
}
output "approach_route_table_id" {
  value = aws_route_table.route_approach.id
}
output "secure_route_table_id" {
  value = aws_route_table.route_secure.id
}
output "workspaces_route_table_id" {
  value = aws_route_table.route_workspaces.id
}

output "db_subnet_group_name" {
  description = "DB Subnet Group name"
  value       = aws_db_subnet_group.common_db_subnet_group.name
}

output "vpn_gateway_id" {
  value = aws_vpn_gateway.vpn_gateway.id
}

