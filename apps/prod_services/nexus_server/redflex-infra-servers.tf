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

resource "aws_instance" "nexus_server" {
  connection {
    user = "core"
    private_key = file(var.key_path)
  }
  # subnet ID for our VPC
  subnet_id = var.subnet_id
  instance_type = var.instance_type
  ami = data.aws_ami.coreos_ami.id
  key_name = var.key_name
  vpc_security_group_ids = [
    var.security_group_id]
  disable_api_termination = true
  user_data = file("${path.module}/resources/cloud_config.yml")

  # We set the name as a tag
  tags {
    "Name" = "AWS-NEXUS01"
    "Project" = "Bamboo"
  }

  root_block_device {
    volume_size = 30
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "st1"
    volume_size = 700
    snapshot_id = var.nexus_snapshot_id
  }

  provisioner "file" {
    source = "resources/"
    destination = "/tmp"
  }
}

resource "aws_route53_record" "nexus_server" {
  zone_id = var.route53_zone_id
  name = "nexusint.rtsprod.net"
  type = "A"
  ttl = "60"
  records = [
    aws_instance.nexus_server.private_ip]
}

resource "aws_route53_record" "nexus_server_cname" {
  zone_id = var.route53_zone_id
  name = "*.${aws_route53_record.nexus.name}"
  type = "CNAME"
  ttl = "60"
  records = [
    aws_route53_record.nexus.name]
}

#Provision the server after attaching the EBS volume
resource "null_resource" "setup_docker_containers" {
  connection {
    host = aws_instance.nexus_server.private_ip
    user = "core"
    private_key = file(var.key_path)
  }

  depends_on = [
    "aws_instance.nexus_server"]

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "/tmp/setup.sh"
    ]
  }
}

resource "aws_alb" "nexus_alb" {
  name = "LBINTERNALnexus"
  internal = "true"
  security_groups = [
    var.security_group_id]
  subnets = [
    var.subnet_id,
    var.secondary_subnet_id]

  //  access_logs {
  //    bucket        = "rts-elb-access-logs"
  //    bucket_prefix = "nexus"
  //    interval      = 60
  //  }

  tags {
    Name = "LBINTERNALnexus"
    Project = "Nexus"
  }
}

resource "aws_alb_target_group" "nexus_alb_tg" {
  name = "${aws_alb.nexus_alb.name}TG"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  stickiness {
    type = "lb_cookie"
  }
}

resource "aws_alb_target_group_attachment" "nexus_alb_tg_attachment" {
  target_group_arn = aws_alb_target_group.nexus_alb_tg.arn
  target_id = aws_instance.nexus_server.id
  port = 80
}

resource "aws_alb_target_group" "nexus_docker_alb_tg" {
  name = "${aws_alb.nexus_alb.name}DockerTG"
  port = 18443
  protocol = "HTTP"
  vpc_id = var.vpc_id
  stickiness {
    type = "lb_cookie"
  }
}

resource "aws_alb_target_group_attachment" "nexus_docker_alb_tg_attachment" {
  target_group_arn = aws_alb_target_group.nexus_docker_alb_tg.arn
  target_id = aws_instance.nexus_server.id
  port = 18443
}

resource "aws_alb_listener" "nexus_alb_tg_listener" {
  load_balancer_arn = aws_alb.nexus_alb.arn
  port = "80"
  protocol = "HTTP"
  //  ssl_policy        = "ELBSecurityPolicy-2015-05"
  //  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    target_group_arn = aws_alb_target_group.nexus_alb_tg.arn
    type = "forward"
  }
}

resource "aws_alb_listener_rule" "host_based_routing" {
  listener_arn = aws_alb_listener.nexus_alb_tg_listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.nexus_docker_alb_tg.arn
  }

  condition {
    field  = "host-header"
    values = ["docker.*"]
  }
}

resource "aws_route53_record" "nexus" {
  zone_id = var.route53_zone_id
  name = "nexus.rtsprod.net"
  type = "CNAME"
  ttl = "60"
  records = [
    aws_alb.nexus_alb.dns_name]
}

resource "aws_route53_record" "docker" {
  zone_id = var.route53_zone_id
  name = "docker.rtsprod.net"
  type = "CNAME"
  ttl = "60"
  records = [
    aws_alb.nexus_alb.dns_name]
}

resource "aws_route53_record" "sonar" {
  zone_id = var.route53_zone_id
  name = "sonar.rtsprod.net"
  type = "CNAME"
  ttl = "60"
  records = [
    aws_alb.nexus_alb.dns_name]
}