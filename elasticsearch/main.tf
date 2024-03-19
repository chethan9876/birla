locals {
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  application = lower(trimspace(var.application))
  es_domain_name = "${local.environment}-${local.client}-${var.application}-es"
}

provider aws {
  profile = var.client
  region = var.region
}

provider aws {
  alias = "route53"
  profile = var.client == "us-govcloud" ? "us-govcloud-parent" : var.client
  region = "us-east-1"
}

resource "aws_elasticsearch_domain" "es_domain" {
  domain_name = local.es_domain_name
  elasticsearch_version = var.es_version

  cluster_config {
    instance_type = var.es_instance_type
    instance_count = var.es_instance_count
    zone_awareness_enabled = "true"
  }

  ebs_options {
    ebs_enabled = "true"
    volume_size = var.es_ebs_size
  }

  encrypt_at_rest {
    enabled = "true"
    kms_key_id = var.es_kms_key_arn
  }

  node_to_node_encryption {
    enabled = true
  }

  vpc_options {
    security_group_ids = [
      aws_security_group.es_security_group.id]
    subnet_ids = var.subnet_ids
  }

  snapshot_options {
    automated_snapshot_start_hour = 14
  }

  tags = {
    Environment = local.environment
    Name = local.es_domain_name
    Application = local.application
    Client = local.client
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
    override_main_response_version = "false"
  }

  lifecycle {
    ignore_changes = [ebs_options]
  }
}

resource "aws_elasticsearch_domain_policy" "es_domain_policy" {
  domain_name = aws_elasticsearch_domain.es_domain.domain_name

  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "${aws_elasticsearch_domain.es_domain.arn}/*"
        }
    ]
}
POLICIES
}

resource "aws_security_group" "es_security_group" {
  name = "${local.es_domain_name}-sg"
  description = "Security group for ${local.es_domain_name} ES"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "${local.es_domain_name}-sg"
    Apllication = local.application
    Client = local.client
    Environment = local.environment
  }
}

resource "aws_security_group_rule" "es_security_group_ingress_cluster" {
  type = "ingress"
  security_group_id = aws_security_group.es_security_group.id
  from_port = 443
  to_port = 443
  protocol = "tcp"
  source_security_group_id = var.eks_cluster_security_group_id
}

resource "aws_security_group_rule" "es_security_group_ingress_admin" {
  type = "ingress"
  security_group_id = aws_security_group.es_security_group.id
  from_port = 443
  to_port = 443
  protocol = "tcp"
  source_security_group_id = var.eks_cluster_admin_security_group_id
}

resource "aws_security_group_rule" "es_security_group_ingress_es" {
  type = "ingress"
  security_group_id = aws_security_group.es_security_group.id
  from_port = 443
  to_port = 443
  protocol = "tcp"
  source_security_group_id = aws_security_group.es_security_group.id
}

resource "aws_security_group_rule" "es_security_group_ingress_jumpbox" {
  type = "ingress"
  security_group_id = aws_security_group.es_security_group.id
  from_port = 443
  to_port = 443
  protocol = "tcp"
  source_security_group_id = var.jumpbox_security_group_id
}

resource "aws_security_group_rule" "es_security_group_ingress_lamba_take_snapshot" {
  type = "ingress"
  security_group_id = aws_security_group.es_security_group.id
  from_port = 443
  to_port = 443
  protocol = "tcp"
  source_security_group_id = module.take_snapshot_lambda_function.lambda_sg_id
}

resource "aws_security_group_rule" "es_security_group_ingress_lamba_delete_indices" {
  type = "ingress"
  security_group_id = aws_security_group.es_security_group.id
  from_port = 443
  to_port = 443
  protocol = "tcp"
  source_security_group_id = module.delete_indices_lambda_function.lambda_sg_id
}

resource "aws_security_group_rule" "es_security_group_ingress_create_repo" {
  type = "ingress"
  security_group_id = aws_security_group.es_security_group.id
  from_port = 443
  to_port = 443
  protocol = "tcp"
  source_security_group_id = module.create_repo_lambda_function.lambda_sg_id
}

data "aws_iam_roles" "es_service_linked_role" {
  name_regex = "AWSServiceRoleForAmazonElasticsearchService"
}

resource "aws_iam_service_linked_role" "es_service_linked_role" {
  count = length(data.aws_iam_roles.es_service_linked_role) == 0 ? 1 : 0
  aws_service_name = "es.amazonaws.com"

//  tags = {
//    Name = "${local.es_domain_name}-linked role"
//    Client = local.client
//    Application = local.application
//    Environment = local.environment
//  }
}

resource "aws_route53_record" "es_domain" {
  provider = aws.route53
  zone_id = var.hosted_zone_id
  name = "${var.application}.${var.hosted_zone_name}"
  type = "CNAME"
  ttl = "60"
  records = [
    aws_elasticsearch_domain.es_domain.endpoint]
}

resource "aws_cloudwatch_metric_alarm" "cpuutilization" {
  count               = var.sns_topic == "" ? 0 : 1
  alarm_name          = "${local.es_domain_name}-CPUUtilization"
  alarm_description   = "This metric monitors cpu utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ES"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "5"
  alarm_actions       = [var.sns_topic]

  dimensions = {
    DomainName = aws_elasticsearch_domain.es_domain.domain_name
    ClientID = data.aws_caller_identity.current.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "free_Storage_Space" {
  count               = var.sns_topic == "" ? 0 : 1
  alarm_name          = "${local.es_domain_name}-FreeStorageSpace"
  alarm_description   = "This metric monitors cpu utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/ES"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "5"
  unit               = "Bytes"
  alarm_actions       = [var.sns_topic]

  dimensions = {
    DomainName = aws_elasticsearch_domain.es_domain.domain_name
    ClientID = data.aws_caller_identity.current.account_id
  }
}
data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_metric_alarm" "cluster_status_yellow" {
  count               = var.sns_topic == "" ? 0 : 1
  alarm_name          = "${local.es_domain_name}-ClusterStatus.yellow"
  alarm_description   = "This metric monitors ClusterStatus.yellow"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ClusterStatus.yellow"
  namespace           = "AWS/ES"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_actions       = [var.sns_topic]

  dimensions = {
    DomainName = aws_elasticsearch_domain.es_domain.domain_name
    ClientID = data.aws_caller_identity.current.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_status_red" {
  count               = var.sns_topic == "" ? 0 : 1
  alarm_name          = "${local.es_domain_name}-ClusterStatus.red"
  alarm_description   = "This metric monitors ClusterStatus.yellow"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ClusterStatus.red"
  namespace           = "AWS/ES"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_actions       = [var.sns_topic]

  dimensions = {
    DomainName = aws_elasticsearch_domain.es_domain.domain_name
    ClientID = data.aws_caller_identity.current.account_id
  }
}