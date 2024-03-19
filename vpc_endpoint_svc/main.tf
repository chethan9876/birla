locals {
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  application = lower(trimspace(var.application))
  prefix = "${local.environment}-${local.client}"
  name = lower(trimspace(var.name))
  vpc_endpoint_name = "${local.prefix}-${local.name}-vpce-svc"
}

module "vpce_svc_nlb" {
  source = "../load_balancer"
  application = local.application
  client = local.client
  environment = local.environment
  function = "vpce-svc"
  subnet_ids = var.subnet_ids
  lb_type = "network"
  certificate_arn = var.certificate_arn
  vpc_id = var.vpc_id
  target_type = "ip"
  port = 443
  protocol = "TCP"
}

resource "aws_lb_target_group_attachment" "endpoint_svc_tg_attachment_1" {
  target_group_arn = module.vpce_svc_nlb.target_group_arn
  target_id        = var.vpce_network_interface_ip_1
  port             = 443
}

resource "aws_lb_target_group_attachment" "endpoint_svc_tg_attachment_2" {
  target_group_arn = module.vpce_svc_nlb.target_group_arn
  target_id        = var.vpce_network_interface_ip_2
  port             = 443
}

resource "aws_lb_target_group_attachment" "endpoint_svc_tg_attachment_3" {
  target_group_arn = module.vpce_svc_nlb.target_group_arn
  target_id        = var.vpce_network_interface_ip_3
  port             = 443
}

resource "aws_vpc_endpoint_service" "endpoint_svc" {
  acceptance_required        = true
  network_load_balancer_arns = [module.vpce_svc_nlb.load_balancer_arn]
  allowed_principals = var.allowed_principals
  private_dns_name = var.private_dns_name

  tags = {
    Name = local.vpc_endpoint_name
    Client = var.client
    Environment = var.environment
    Application = var.application
  }
}

resource "aws_route53_record" "endpoint_svc_private_dns_record" {
  count = var.private_dns_name == "" ? 0 : 1
  zone_id = var.zone_id
  name    = aws_vpc_endpoint_service.endpoint_svc.private_dns_name_configuration[0].name
  type    = aws_vpc_endpoint_service.endpoint_svc.private_dns_name_configuration[0].type
  ttl     = 300
  records = [aws_vpc_endpoint_service.endpoint_svc.private_dns_name_configuration[0].value]
  depends_on = [aws_vpc_endpoint_service.endpoint_svc]
}