locals {
  application = lower(trimspace(var.application))
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  elasticache_cluster_name = "${local.environment}-${local.client}-${local.application}-redis"
}

provider aws {
  alias = "route53"
  profile = var.client == "us-govcloud" ? "us-govcloud-parent" : var.client
  region = "us-east-1"
}

resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  name       = "${local.elasticache_cluster_name}-group"
  subnet_ids = var.database_subnet_ids

  tags = {
    Name        = "${local.elasticache_cluster_name}-subnet-group"
    Environment = local.environment
    Application = local.application
    Client = local.client
  }
}

resource "aws_elasticache_parameter_group" "elasticache_param_group" {
  name = "${local.elasticache_cluster_name}-param-group"
  family = var.elasticache_param_group_family

  tags = {
    Name        = "${local.elasticache_cluster_name}-param-group"
    Environment = local.environment
    Application = local.application
    Client = local.client
  }
}

resource "aws_elasticache_replication_group" "elasticache_cluster_replication_group" {
  replication_group_id          = local.elasticache_cluster_name
  replication_group_description = "${local.elasticache_cluster_name}-cluster"
  engine                        = "redis"
  node_type                     = var.elasticache_node_type
  port                          = 6379
  automatic_failover_enabled    = true
  parameter_group_name          = aws_elasticache_parameter_group.elasticache_param_group.id
  engine_version                = var.elasticache_engine_version
  subnet_group_name             = aws_elasticache_subnet_group.elasticache_subnet_group.name
  security_group_ids            = [aws_security_group.elasticache_security_group.id]
  snapshot_retention_limit      = 35
  at_rest_encryption_enabled    = false
  final_snapshot_identifier     = "${local.elasticache_cluster_name}-final-snapshot"

  cluster_mode {
    replicas_per_node_group = var.elasticache_replica_count
    num_node_groups         = 1
  }

  tags = {
    Name = "${local.elasticache_cluster_name}-replication-group"
    Application = local.application
    Environment = local.environment
    Client = local.client
  }

  lifecycle {
    ignore_changes = [cluster_mode]
  }
}

resource "aws_security_group" "elasticache_security_group" {
  name = "${local.elasticache_cluster_name}-sg"
  vpc_id = var.vpc_id
  description = "${local.elasticache_cluster_name} security group"

  tags = {
    Name = "${local.elasticache_cluster_name}-sg"
    Client = local.client
    Application = local.application
    Environment = local.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "cpuutilisation" {
  count = var.sns_topic == "" ? 0 : var.elasticache_replica_count
  alarm_name            = "${local.elasticache_cluster_name}-00${count.index + 1}-CPUUtilization-Alarm"
  comparison_operator   = "GreaterThanThreshold"
  evaluation_periods    = "2"
  metric_name           = "CPUUtilization"
  namespace             = "AWS/ElastiCache"
  period                = "300"
  statistic             = "Average"
  threshold             = "95"
  alarm_actions         = [var.sns_topic]

  dimensions = {
    CacheClusterId = "${aws_elasticache_replication_group.elasticache_cluster_replication_group.id}-00${count.index + 1}"
  }
  
  alarm_description = "This metric monitors ec2 cpu utilization"
}


resource "aws_cloudwatch_metric_alarm" "freeablememory" {
  count = var.sns_topic == "" ? 0 : var.elasticache_replica_count
  alarm_name            = "${local.elasticache_cluster_name}-00${count.index + 1}-Statuscheck-Alarm"
  comparison_operator   = "GreaterThanThreshold"
  evaluation_periods    = "2"
  metric_name           = "FreeableMemory"
  namespace             = "AWS/ElastiCache"
  period                = "300"
  statistic             = "Maximum"
  threshold             = "5"
  alarm_actions         = [var.sns_topic]

  dimensions = {
    CacheClusterId = "${aws_elasticache_replication_group.elasticache_cluster_replication_group.id}-00${count.index + 1}"
  }

  alarm_description = "This metric monitors system status check"
}