locals {
  application = lower(trimspace(var.application))
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  name = lower(trimspace(var.name))
  queue_name = "${local.environment}-${local.client}-${local.application}-${local.name}-sqs"
}

resource "aws_sqs_queue" "sqs_queue" {
  name = local.queue_name
  visibility_timeout_seconds = var.visibility_timeout_seconds
  delay_seconds = var.delay_seconds
  kms_master_key_id = var.sqs_kms_key_arn
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_queue_dlq.arn
    maxReceiveCount = var.max_receive_count
  })

  tags = {
    Name = local.queue_name
    Client = local.client
    Application = local.application
    Environment = local.environment
  }
}

resource "aws_sqs_queue" "sqs_queue_dlq" {
  name = "${local.queue_name}-dlq"
  kms_master_key_id = var.sqs_kms_key_arn

  tags = {
    Name = "${local.queue_name}-dlq"
    Client = local.client
    environment = local.environment
    Application = local.application
  }
}

resource "aws_cloudwatch_metric_alarm" "sqs_dlq_alarm" {
  alarm_name                = "${local.queue_name}-dlq-alarm-cloudwatch"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "ApproximateNumberOfMessagesVisible"
  namespace                 = "AWS/SQS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "0"
  alarm_description         = "This metric monitors ${local.queue_name}-dlq"
  actions_enabled           = "true"
  alarm_actions             = [var.alarm_sns_topic_arn]
  ok_actions                = [var.alarm_sns_topic_arn]
  insufficient_data_actions = []
  dimensions = {
    QueueName = aws_sqs_queue.sqs_queue_dlq.name
  }

  tags = {
    Name = "${local.queue_name}-dlq-alarm-cloudwatch"
    Client = local.client
    Application = local.application
    Environment = local.environment
  }
}