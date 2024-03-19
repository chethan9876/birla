variable "environment" {
  description = "The aws environment for the s3 bucket. Eg: dev, stg, prd."
  type = string
  validation {
    condition = length(trimspace(var.environment)) > 0
    error_message = "The value environment cannot be empty."
  }
}

variable "name" {
  description = "The bucket name. Eg: media."
  type = string
  validation {
    condition = length(trimspace(var.name)) > 0
    error_message = "The value name cannot be empty."
  }
}

variable "client" {
  description = "The client name (geography based convention). Eg: ca-sk for Canada Saskatchewan."
  type = string
  validation {
    condition = length(trimspace(var.client)) > 0
    error_message = "The value client cannot be empty."
  }
}

variable "application" {
  description = "The application name Eg: alcyon."
  type = string
  validation {
    condition = length(trimspace(var.application)) > 0
    error_message = "The value application cannot be empty."
  }
}

variable "s3_log_bucket" {
  description = "S3 log bucket name."
  type = string
  validation {
    condition = length(trimspace(var.s3_log_bucket)) > 0
    error_message = "The value s3_log_bucket cannot be empty."
  }
}

variable "aws_kms_s3_key_arn" {
  description = "KMS S3 Key ARN."
  type = string
  validation {
    condition = length(trimspace(var.aws_kms_s3_key_arn)) > 0
    error_message = "The value aws_kms_s3_key_arn cannot be empty."
  }
}

variable "s3_lifecycle_rules" {
  description = "S3 Lifecycle Rules."
  type = list(object({
    enabled = bool
    prefix = string
    current_version_transitions = list(object({
      storage_class = string
      days = number
    }))
    noncurrent_version_transitions = list(object({
      storage_class = string
      days = number
    }))
    current_version_expiration_days = number
    noncurrent_version_expiration_days = number
  }))
  default = [
    {
      enabled = true
      prefix = ""
      current_version_transitions = [
        {
          storage_class = "STANDARD_IA"
          days = 30
        }
      ],
      current_version_expiration_days = null
      noncurrent_version_transitions = [],
      noncurrent_version_expiration_days = 15
    }
  ]
}

variable "cors_rules" {
  description = "S3 CORS Rules."
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers = list(string)
    max_age_seconds = number
  }))
  default = []
}

variable "replication_configuration" {
  description = "S3 cross-region replication configuration."
  type = list(object({
    s3_replication_role_arn = string
    rules = list(object({
      status = string
      destination = list(object({
        bucket = string
        storage_class = string
      }))
    }))
  }))
  default = []
}