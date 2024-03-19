output "private_ip" {
  description = "Private IP of the linux host created."
  value = aws_instance.linux_host.private_ip
}

output "public_ip" {
  description = "Private IP of the linux host created."
  value = aws_instance.linux_host.public_ip
}