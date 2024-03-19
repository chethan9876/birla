provider "aws" {
  profile = var.client
  region  = var.region
}

provider "aws" {
  alias   = "route53"
  profile = var.client
  region  = "us-east-1"
}

module "filecatalyst" {
  source                      = "../../../../templates/ec2/linux"
  client                      = local.client
  environment                 = local.environment
  region                      = var.region
  iam_arn_prefix              = var.iam_arn_prefix
  ec2_description             = "filecatalyst"
  ec2_securitygroups          = [aws_security_group.jumpbox_security_group.id]
  vpc_id                      = var.vpc_id
  subnet_id                   = sort(var.internal_subnet_ids)[0]
  key_name                    = var.ssh_key
  associate_public_ip_address = false
  sns_topic                   = var.sns_topic
  linux_ami                   = ["*ae7cf950-c7e1-46ae-bd5c-c95d7b1453dd"]
  instance_type               = "m5.xlarge"
}

resource "aws_route53_record" "jumbox_route53_record" {
  provider = aws.route53
  zone_id  = var.hosted_zone_id
  name     = "filecatalyst.${var.hosted_zone_name}"
  type     = "A"
  ttl      = "60"
  records  = [module.filecatalyst.private_ip]
}

resource "aws_security_group" "jumpbox_security_group" {
  name        = "${local.prefix}-filecatalyst-sg"
  description = "Security group for ${local.prefix} filecatalyst"
  vpc_id      = var.vpc_id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  tags = {
    Name = "${local.prefix}-filecatalyst-sg"
  }
}

resource "aws_security_group_rule" "jumpbox_security_group_rule" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.jumpbox_security_group.id
  source_security_group_id = var.jumpbox_security_group
}
