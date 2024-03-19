locals {
  application = "core-services"
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  prefix = "${local.environment}-${local.client}-${local.application}"
}

resource "aws_s3_bucket" "s3_log_bucket" {
  bucket = "${local.prefix}-access-log-s3"

  versioning {
    enabled = false
  }

  tags = {
    Name = "${local.prefix}-access-log-s3"
    Environment = local.environment
    Project = local.application
  }

  lifecycle_rule {
    id = "current_object_transitions"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 365
      storage_class = "GLACIER"
    }

    expiration {
      days = 730
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = module.s3_kms_key.kms_key_arn
        sse_algorithm = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_log_bucket" {
  bucket = aws_s3_bucket.s3_log_bucket.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "s3_log_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_log_bucket]

  bucket = aws_s3_bucket.s3_log_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_public_access_block" "s3_log_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_log_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

module "sqs_dlq_sns_topic" {
  source = "../../templates/sns"
  application = local.application
  client = local.client
  environment = var.environment
  kms_key_id = module.sns_kms_key.kms_key_arn
  name = "sqs-dlq-alarm"
  feedback_role_arn = aws_iam_role.sns_feedback_role.arn
}

resource "aws_sns_topic_subscription" "pagerduty_subscription" {
  topic_arn = module.sqs_dlq_sns_topic.sns_topic_arn
  protocol  = "https"
  endpoint = "https://events.pagerduty.com/integration/${var.pagerduty_integration_key}/enqueue"
  endpoint_auto_confirms = true
}