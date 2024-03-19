locals {
  application = lower(trimspace(var.application))
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  name = lower(trimspace(var.name))
  cluster_name = "${local.environment}-${local.client}-${local.application}-${local.name}-msk"
}

resource "aws_msk_cluster" "msk_cluster" {
  cluster_name           = local.cluster_name
  kafka_version          = var.msk_version
  number_of_broker_nodes = var.msk_broker_count

  broker_node_group_info {
    instance_type   = var.msk_instance_type
    ebs_volume_size = var.msk_ebs_size
    client_subnets = var.subnet_ids
    security_groups = [aws_security_group.msk_security_group.id]
  }

  client_authentication {
    sasl {
      scram = true
    }
  }

  tags = {
    Name = "${local.cluster_name}-mskcluster"
    Environment = local.environment
    Client = local.client
    Application = local.application

  }

  encryption_info {
    encryption_at_rest_kms_key_arn = var.msk_kms_key_arn
  }
}

resource "aws_msk_scram_secret_association" "cluster_secret" {
  cluster_arn = aws_msk_cluster.msk_cluster.arn
  secret_arn_list = [aws_secretsmanager_secret.msk_secret_password.arn]
}

resource "aws_cloudwatch_metric_alarm" "MemoryFree" {
  count = var.sns_topic == "" ? 0 : var.msk_broker_count
  alarm_name            = "${local.cluster_name}-memoryfree-Alaram"
  alarm_description     = "This metric monitors msk memoryfree utilization"
  comparison_operator   = "GreaterThanThreshold"
  evaluation_periods    = "2"
  metric_name           = "MemoryFree"
  namespace             = "AWS/Kafka"
  period                = "300"
  statistic             = "Average"
  threshold             = "95"
  alarm_actions         = [var.sns_topic]

  dimensions = {
    ClusterName = aws_msk_cluster.msk_cluster.cluster_name
    BrokerID    = count.index + 1
  }

  lifecycle {
    ignore_changes = [dimensions]
  }
}

resource "aws_cloudwatch_metric_alarm" "RootDiskUsed" {
  count = var.sns_topic == "" ? 0 : var.msk_broker_count
  alarm_name            = "${local.cluster_name}-rootdiskused-Alaram"
  alarm_description     = "This metric monitors msk RootDiskused utilization"
  comparison_operator   = "GreaterThanThreshold"
  evaluation_periods    = "2"
  metric_name           = "RootDiskUsed"
  namespace             = "AWS/Kafka"
  period                = "300"
  statistic             = "Average"
  threshold             = "95"
  alarm_actions         = [var.sns_topic]

  dimensions = {
    ClusterName = aws_msk_cluster.msk_cluster.cluster_name
    BrokerID    = count.index + 1
  }

  lifecycle {
    ignore_changes = [dimensions["BrokerID"]]
  }
}