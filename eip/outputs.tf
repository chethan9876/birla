output "eip_allocation_id" {
  description = "The allocation id for the EIP created."
  value = aws_eip.eip.allocation_id
}