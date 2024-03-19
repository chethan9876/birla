module "sftp" {
  source = "../../../../templates/sftp/server"
  //count = var.environment == "uat" ? 1 : 0
  application = local.application
  client = local.client
  environment = local.environment
  vpc_id = var.vpc_id
  certificate_arn = var.certificate_arn
  hosted_zone_id = var.hosted_zone_id
  hosted_zone_name = var.hosted_zone_name
  subnet = var.dmz_subnet
  sftp_domain = "EFS"
  //cidr_blocks = var.allowed_ips
}

module "sftp_user" {
  source = "../../../../templates/sftp/user"
  application = local.application
  client = local.client
  environment = local.environment
  service_arn = var.efs_arn
  sftp_domain = "EFS"
  user = "ingestr"
  home_folder = "/ingestr"
  sftp_server_id = module.sftp.sftp_server_id
  service_id = var.efs_id
}

resource "aws_security_group_rule" "sftp_ingress_security_group_rule" {
  //count = var.environment == "uat" ? 1 : 0
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = module.sftp.sftp_security_group_id
  cidr_blocks = var.allowed_ips
}