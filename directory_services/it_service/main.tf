locals {
  application = "itservice"
  client      = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  prefix      = "${local.environment}-${local.client}-${local.application}"
}

//provider "aws" {
//  profile = var.profile
//  region  = var.region
//  ignore_tags {
//    key_prefixes = ["kubernetes.io/"]
//  }
//}

resource "random_shuffle" "itservice_subnet_id" {
  input = var.subnet_ids
  result_count = 1
}

resource "aws_instance" "itservice_ec2" {
  ami = var.itservice_ami
  instance_type = var.itservice_instance_type
  key_name = var.itservice_ssh_key
  subnet_id = random_shuffle.itservice_subnet_id.result.0
  vpc_security_group_ids = [
    aws_security_group.itservice_security_group.id    ]
  ebs_optimized = true
  monitoring = false
  instance_initiated_shutdown_behavior = "stop"
  disable_api_termination = false
  associate_public_ip_address = false

  credit_specification {
    cpu_credits = "unlimited"
  }

  root_block_device {
    volume_size = var.itservice_disk_size

    tags = {
      Name = "${local.prefix}-ebs"
      Environment = local.environment
      Client = local.client
      Application = local.application
    }
  }

  tags = {
    Name           = "${local.prefix}-ec2",
    standardbackup = "enabled"
    Environment = local.environment
    Client = local.client
    Application = local.application
  }

  lifecycle {
    ignore_changes = [ami, iam_instance_profile]
  }
}
