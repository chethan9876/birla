module "jumpbox" {
  source = "../../templates/ec2/linux"
  client = local.client
  environment = local.environment
  region = var.region
  iam_arn_prefix = var.iam_arn_prefix
  ec2_description = "jumpbox"
  ec2_securitygroups = [ aws_security_group.jumpbox_security_group.id ]
  vpc_id = var.vpc_id
  subnet_id = sort(var.dmz_ids)[0]
  key_name = var.jumpbox_ssh_key
  associate_public_ip_address = true
  sns_topic = var.sns_topic
}

resource "aws_route53_record" "jumbox_route53_record" {
  provider = aws.route53
  zone_id = module.hosted_zone.hosted_zone_id
  name = "jumpbox.${module.hosted_zone.hosted_zone_name}"
  type = "A"
  ttl = "60"
  records = [module.jumpbox.public_ip]
}

resource "aws_security_group" "jumpbox_security_group" {
  name = "${local.prefix}-jumpbox-sg"
  description = "Security group for ${local.prefix} jumpbox"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "${local.prefix}-jumpbox-sg"
  }
}

resource "aws_security_group_rule" "jumpbox_security_group_rule" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.jumpbox_security_group.id
  cidr_blocks = var.jumpbox_allowed_cidr
}
