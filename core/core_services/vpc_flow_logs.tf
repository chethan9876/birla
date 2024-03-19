resource "aws_s3_bucket" "vpc_flow_log_bucket" {
  bucket = "${local.prefix}-vpc-flow-log-s3"

  versioning {
    enabled = false
  }

  tags = {
    Name = "${local.prefix}-vpc-flow-log-s3"
    Environment = local.environment
    Project = local.application
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = module.s3_kms_key.kms_key_arn
        sse_algorithm = "aws:kms"
      }
    }
  }
  policy = data.aws_iam_policy_document.s3_flow_log_policy.json

  lifecycle_rule {
    id = "current_object_transitions"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 180
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_public_access_block" "vpc_flow_log_bucket_public_access_block" {
  bucket = aws_s3_bucket.vpc_flow_log_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_flow_log" "vpc_flow_log" {
  log_destination = aws_s3_bucket.s3_log_bucket.arn
  log_destination_type = "s3"
  traffic_type = "ALL"
  vpc_id = var.vpc_id
//  iam_role_arn = aws_iam_role.vpc_flow_logs_policy.arn
}