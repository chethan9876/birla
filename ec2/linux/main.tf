locals {
  application = "linux-host"
  client      = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  prefix      = "${local.environment}-${local.client}-${local.application}"
}

provider "aws" {
  profile = local.client
  region  = var.region
  ignore_tags {
    key_prefixes = ["kubernetes.io/"]
  }
}

data "template_file" "linux_host_user_data" {
  template = file("${path.module}/scripts/user_data.sh")

  vars = {
    DOMAIN_ADMIN_PASSWORD = jsondecode(data.aws_secretsmanager_secret_version.domain_secret_current.secret_string)["Password"]
    DOMAIN_ADMIN_USER = jsondecode(data.aws_secretsmanager_secret_version.domain_secret_current.secret_string)["Username"]
    DOMAIN = jsondecode(data.aws_secretsmanager_secret_version.domain_secret_current.secret_string)["Domain"]
    additional_user_data = var.additional_user_data
  }
}

data "aws_iam_policy_document" "linux_host_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      identifiers = [
        "ec2.amazonaws.com"]
      type = "service"
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      data.aws_secretsmanager_secret_version.domain_secret_current.arn
    ]
  }
}

data "aws_ami" "linux_ami" {
  owners      = ["amazon", "345084742485", "679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = var.linux_ami
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }

}

resource "aws_iam_role" "linux_host_role" {
  name = "${local.prefix}-${var.ec2_description}-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
  tags = {
    Name = "${local.prefix}-${var.ec2_description}-linux-host role"
    Client = local.client
    Environment = local.environment
    Application = local.application
  }

}

resource "aws_iam_instance_profile" "linux_host_instance_profile" {
  name = "${local.prefix}-${var.ec2_description}-profile"
  role = aws_iam_role.linux_host_role.name

  tags = {
    Name = "${local.prefix}-${var.ec2_description}-profile" 
    Client = local.client
    Application = local.application
    Environment = local.environment
  }
}

resource "aws_iam_role_policy_attachment" "linux_host_role-policy-attach" {
  role = aws_iam_role.linux_host_role.name
  policy_arn = "${var.iam_arn_prefix}:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_instance" "linux_host" {
  instance_type = var.instance_type
  ami = var.image_id == "" ? data.aws_ami.linux_ami.id : var.image_id
  key_name = var.key_name == "" ? null : var.key_name
  iam_instance_profile = aws_iam_instance_profile.linux_host_instance_profile.name
  vpc_security_group_ids = var.ec2_securitygroups
  subnet_id = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  disable_api_termination = var.disable_api_termination
  user_data = data.template_file.linux_host_user_data.rendered
  monitoring = var.monitoring
  ebs_optimized = var.ebs_optimized

  credit_specification {
    cpu_credits = var.cpu_credits
  }

  root_block_device {
    volume_size = var.root_block_device
  }

  tags = {
    Name = "${local.prefix}-${var.ec2_description}-ec2"
    Application = local.application
    Environment = local.environment
    Client = local.client
  }

  lifecycle {
    ignore_changes = [ root_block_device, ami, instance_type, user_data ]
  }
  
}

resource "aws_cloudwatch_metric_alarm" "cpuutilisation" {
  count = var.sns_topic == "" ? 0 : 1
  alarm_name            = "${local.prefix}-${var.ec2_description}-ec2-cpuutilization-Alaram"
  comparison_operator   = "GreaterThanThreshold"
  evaluation_periods    = "2"
  metric_name           = "CPUUtilization"
  namespace             = "AWS/EC2"
  period                = "300"
  statistic             = "Average"
  threshold             = "95"
  alarm_actions         = [var.sns_topic]
  
  dimensions = {
   InstanceId = aws_instance.linux_host.id
   
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
}


resource "aws_cloudwatch_metric_alarm" "statuscheck" {
  alarm_name          = "${local.prefix}-${var.ec2_description}-ec2-statuscheck-Alaram"
  count = var.sns_topic == "" ? 0 : 1
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "5"
  alarm_actions       = [var.sns_topic]
  

  dimensions = {
   InstanceId = aws_instance.linux_host.id
  }

  alarm_description = "This metric monitors system status check"
}
