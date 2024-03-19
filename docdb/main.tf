locals {
  application = lower(trimspace(var.application))
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  docdb_cluster_name = "${local.environment}-${local.client}-${local.application}-docdb"
}

provider aws {
  alias = "route53"
  profile = var.client == "us-govcloud" ? "us-govcloud-parent" : var.client
  region = "us-east-1"
}

module "master_password" {
  source = "../secrets_manager/secret"
  secret_prefix = "${local.environment}-${local.client}-${local.application}-docdb"
}

data "aws_secretsmanager_secret" "docdb_secret" {
  name = module.master_password.secret_name
}

data "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = data.aws_secretsmanager_secret.docdb_secret.id
}

resource "aws_docdb_subnet_group" "docdb_subnet_group" {
  name       = "${local.docdb_cluster_name}-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = {
    Name        = "${local.docdb_cluster_name}-subnet-group"
    Environment = local.environment
    Application = local.application
    Client = local.client
  }
}

resource "aws_docdb_cluster_parameter_group" "docdb_parameter_group" {
  family      = var.docdb_param_group_family
  name        = "${local.docdb_cluster_name}-parameter-group"
  description = "${local.docdb_cluster_name}-parameter-group"

  parameter {
    name  = "tls"
    value = var.docdb_param_group_tls_enabled
  }

  tags = {
    Name = "${local.docdb_cluster_name}-parameter-group"
    Application = local.application
    Environment = local.environment
    Client = local.client
  }
}

resource "aws_docdb_cluster" "cluster" {
  cluster_identifier              = "${local.docdb_cluster_name}-cluster"
  engine_version                  = var.docdb_engine_version
  backup_retention_period         = "35"
  master_username                 = "mongo"
  master_password                 = data.aws_secretsmanager_secret_version.rds_secret_version.secret_string
  db_subnet_group_name            = aws_docdb_subnet_group.docdb_subnet_group.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.docdb_parameter_group.id
  kms_key_id                      = var.docdb_kms_key_arn
  storage_encrypted               = true
  snapshot_identifier             = var.docdb_snapshot_identifier
  vpc_security_group_ids          = [aws_security_group.docdb_security_group.id]
  deletion_protection             = "true"
  final_snapshot_identifier       = "${local.docdb_cluster_name}-final-snapshot"

  tags = {
    Name = "${local.docdb_cluster_name}-docdb-cluster"
    Application = local.application
    Environment = local.environment
    Client = local.client
  }
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = var.docdb_instance_count
  identifier         = "${local.docdb_cluster_name}-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.cluster.cluster_identifier
  instance_class     = var.docdb_instance_class

  tags = {
    Name = local.docdb_cluster_name
    Application = local.application
    Environment = local.environment
    Client = local.client
  }
}

resource "aws_security_group" "docdb_security_group" {
  name = "${local.docdb_cluster_name}-sg"
  vpc_id = var.vpc_id
  description = "${local.docdb_cluster_name} security group"

  tags = {
    Name = "${local.docdb_cluster_name}-sg"
    Application = local.application
    Environment = local.environment
    Client = local.client
  }
}

resource "aws_cloudwatch_metric_alarm" "CPUUtilization" {
  alarm_name          = "${local.docdb_cluster_name}-cpuutilization-alarm"
  count = var.sns_topic == "" ? 0 : 1
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/DocDB"
  period              = "300"
  statistic           = "Average"
  threshold           = "95"
  alarm_actions       = [var.sns_topic]

  dimensions = {
    InstanceId = aws_docdb_cluster.cluster.id
  }

  alarm_description = "This metric monitors documentdb cpu utilization"
}

resource "aws_cloudwatch_metric_alarm" "FreeableMemory" {
  alarm_name          = "${local.docdb_cluster_name}-freeablememory-alarm"
  count = var.sns_topic == "" ? 0 : 1
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/DocDB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1000"
  alarm_actions       = [var.sns_topic]

  dimensions = {
    InstanceId = aws_docdb_cluster.cluster.id
  }

  alarm_description = "This metric monitors documentdb freeable memory"
}

resource "aws_cloudwatch_metric_alarm" "FreeLocalStorage" {
  count = var.sns_topic == "" ? 0 : 1
  alarm_name            = "${local.docdb_cluster_name}-freelocalstorage-alarm"
  comparison_operator   = "GreaterThanThreshold"
  evaluation_periods    = "2"
  metric_name           = "FreeLocalStorage"
  namespace             = "AWS/DocDB"
  period                = "300"
  statistic             = "Average"
  threshold             = "1000"
  alarm_actions         = [var.sns_topic]

  dimensions = {
    InstanceId = aws_docdb_cluster.cluster.id
  }

  alarm_description = "This metric monitors documentdb FreeLocalStorage utilization"
}
