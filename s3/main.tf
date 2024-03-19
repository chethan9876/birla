locals {
  application = lower(trimspace(var.application))
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  name = lower(trimspace(var.name))
  bucket_name = "${local.environment}-${local.client}-${local.application}-${local.name}-s3"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = local.bucket_name
  acl = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name = local.bucket_name
    Environment = local.environment
    Application = local.application
    Client = local.client
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.aws_kms_s3_key_arn
        sse_algorithm = "aws:kms"
      }
    }
  }

  logging {
    target_bucket = var.s3_log_bucket
    target_prefix = "${local.bucket_name}-log/"
  }

  dynamic "lifecycle_rule" {
    for_each = var.s3_lifecycle_rules
    content {
      enabled = lifecycle_rule.value.enabled
      prefix = lifecycle_rule.value.prefix

      dynamic "transition" {
        for_each = lifecycle_rule.value.current_version_transitions
        content {
          storage_class = transition.value.storage_class
          days = transition.value.days
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lifecycle_rule.value.noncurrent_version_transitions
        content {
          storage_class = noncurrent_version_transition.value.storage_class
          days = noncurrent_version_transition.value.days
        }
      }

      dynamic "expiration" {
        for_each = lifecycle_rule.value.current_version_expiration_days == null ? [] : [lifecycle_rule.value.current_version_expiration_days]
        content {
          days = expiration.value
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lifecycle_rule.value.noncurrent_version_expiration_days == null ? [] : [lifecycle_rule.value.noncurrent_version_expiration_days]
        content {
          days = noncurrent_version_expiration.value
        }
      }
    }
  }

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }

  dynamic "replication_configuration" {
    for_each = var.replication_configuration
    content {
      role = replication_configuration.value.s3_replication_role_arn
      dynamic "rules" {
        for_each = replication_configuration.value.rules
        content {
          status = rules.value.status
          dynamic "destination" {
            for_each = rules.value.destination
            content {
              bucket = destination.value.bucket
              storage_class = destination.value.storage_class
            }
          }
        }
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3-public-access-block" {
  bucket = aws_s3_bucket.s3_bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}