provider "aws" {
  region = var.region
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

resource "aws_instance" "bitbucket_server" {
  instance_type = var.instance_type
  ami = data.aws_ami.coreos_ami.id
  key_name = var.key_name

  vpc_security_group_ids = [
    var.security_group_id]
  subnet_id = var.subnet_id
  associate_public_ip_address = false
  disable_api_termination = false
  user_data = file("${path.module}/resources/cloud_config.yml")

  root_block_device {
    volume_size = 30
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = 60
  }

  tags {
    Name = "AWS-BITBUCKET01"
    Project = "BitBucket"
    Environment = "Prod"
    Team = "CEG"
  }

  connection {
    user = "core"
    private_key = file(var.key_path)
  }

  provisioner "file" {
    source = "${path.module}/resources"
    destination = "/tmp"
  }
}

#Provision the server after attaching the EBS volume
resource "null_resource" "setup_docker_containers" {
  connection {
    host = aws_instance.bitbucket_server.private_ip
    user = "core"
    private_key = file(var.key_path)
  }

  depends_on = [
    "aws_instance.bitbucket_server"
  ]

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/resources/setup.sh",
      "/tmp/resources/setup.sh"
    ]
  }
}

resource "aws_db_instance" "bitbucket_db" {
  allocated_storage = 100
  name = "bitbucketdb"
  username = "bitbucket"
  identifier = "bitbucketdb"
  storage_type = "gp2"
  storage_encrypted = true
  engine = "postgres"
  engine_version = "9.6.5"
  instance_class = "db.t2.medium"
  multi_az = false
  db_subnet_group_name = "privateproddbsubnetgroup"
  kms_key_id = var.kms_key_id
  final_snapshot_identifier = "bitbucket-db-final-snapshot"
  copy_tags_to_snapshot = true
  backup_retention_period = 7
  vpc_security_group_ids = [
    var.security_group_id,
    var.bamboo_security_group_id]

  tags {
    Name = "Bitbucket DB"
    Team = "CEG"
    Environment = "Prod"
  }
}

resource "aws_route53_record" "bitbucket" {
  zone_id = var.route53_zone_id
  name = "bitbucket.rtsprod.net"
  type = "A"
  ttl = "60"
  records = [
    aws_instance.bitbucket_server.private_ip]
}

output "DB endpoint" {
  value = aws_db_instance.bitbucket_db.endpoint
}
