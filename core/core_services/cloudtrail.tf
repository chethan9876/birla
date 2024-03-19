resource "aws_cloudtrail" "cloudtrail" {
  count = var.environment == "prd" ? 1 : 0
  name = "${local.environment}-${local.client}-cloudtrail"
  s3_bucket_name = aws_s3_bucket.cloud_trail_s3.id
  s3_key_prefix = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail = true
  enable_log_file_validation = true
}

resource "aws_s3_bucket" "cloud_trail_s3" {
  bucket = "${local.environment}-${local.client}-cloudtrail-s3"

  versioning {
    enabled = true
  }

  tags = {
    Name = "${local.environment}-${local.client}-cloudtrail-s3"
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

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.cloud_trail_s3.id
  policy = data.aws_iam_policy_document.cloud_trail_s3_policy.json
}

resource "aws_s3_bucket_public_access_block" "cloud_trail_bucket_public_access_block" {
  bucket = aws_s3_bucket.cloud_trail_s3.id

  block_public_acls   = true
  block_public_policy = true
}