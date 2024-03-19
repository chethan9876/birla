data "template_file" "clusteradmin_user_data" {
  template = file("${path.module}/resources/clusteradmin_user_data.sh")
  vars = {
    docker_registry_domain = var.docker_registry_domain
    efs_dns_name = var.efs_dns_name
    region = var.region
    client = local.client
    cluster_name = local.cluster_name
    environment = local.environment
    root_domain = var.root_domain
    pega_layer = local.pega_layer
    additional_user_data = var.additional_user_data
  }
}

module "linux" {
  source = "../../templates/ec2/linux"
  client = local.client
  environment = local.environment
  region = var.region
  iam_arn_prefix = var.iam_arn_prefix
  ec2_description = "ClusterAdmin"
  ec2_securitygroups = [ aws_security_group.cluster_admin_security_group.id, ]
  vpc_id = var.vpc_id
  subnet_id = var.subnet_ids[0]
  key_name = var.cluster_worker_node_ssh_key
  additional_user_data = data.template_file.clusteradmin_user_data.rendered
  instance_type = "t3.small"
  sns_topic     = var.sns_topic
}

resource "aws_route53_record" "cluster_admin" {
  provider = aws.route53
  zone_id = var.hosted_zone_id
  name = "admin.${var.hosted_zone_name}"
  type = "A"
  ttl = "60"
  records = [module.linux.private_ip]
}