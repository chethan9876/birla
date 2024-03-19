provider "aws" {
  region = "ap-southeast-2"
}

data "aws_ami" "coreos_ami" {
  most_recent = true
  filter {
    name = "name"
    values = [
      "CoreOS-stable-${var.core_os_version}-hvm"]
  }
  filter {
    name = "virtualization-type"
    values = [
      "hvm"]
  }
}

resource "aws_instance" "grid_server" {
  instance_type = var.instance_type
  ami = data.aws_ami.coreos_ami.id
  key_name = var.key_name

  vpc_security_group_ids = [var.security_group_id]
  subnet_id = var.subnet_id

  # We set the name as a tag
  tags = {
    "Name" = "AWS-GRIDSERVER-01"
  }

  connection {
    user = "core"
    private_key = file(var.key_path)
  }

  provisioner "file" {
    source = "resources/"
    destination = "/home/core"
  }
}

output "server_private_ip" {
  value = aws_instance.grid_server.private_ip
}

resource "aws_route53_record" "grid" {
  zone_id = var.route53_zone_id
  name = "grid.rtsdev.net"
  type = "A"
  ttl = "60"
  records = [
    aws_instance.grid_server.private_ip]
}

#Provision the server after attaching the EBS volume
resource "null_resource" "setup_docker_containers" {
  connection {
    host = aws_instance.grid_server.private_ip
    user = "core"
    private_key = file(var.key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/core/setup.sh",
      "/home/core/setup.sh"
    ]
  }
}