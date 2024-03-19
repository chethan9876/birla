variable "region" {
  description = "The aws region."
  type = string
  validation {
    condition = length(trimspace(var.region)) > 0
    error_message = "The value region cannot be empty."
  }
}
variable "environment" {
  description = "The aws environment. Eg: dev, stg, prd."
  type = string
  validation {
    condition = length(trimspace(var.environment)) > 0
    error_message = "The value environment cannot be empty."
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

variable "iam_arn_prefix" {
  description = "The IAM ARN prefix. Eg: arn:aws, arn:aws-us-gov."
  type = string
  validation {
    condition = contains([
      "arn:aws",
      "arn:aws-us-gov"
    ], var.iam_arn_prefix)
    error_message = "The value iam_arn_prefix must be one of the following: arn:aws, arn:aws-us-gov."
  }
  default = "arn:aws"
}

variable "application" {
  description = "The application name Eg: alcyon."
  type = string
  validation {
    condition = length(trimspace(var.application)) > 0
    error_message = "The value application cannot be empty."
  }
}

variable "vpc_id" {}
variable "subnet_ids" {
  description = "App Subnet IDs across different Availability Zones in the region"
  type = set(string)
  validation {
    condition = length(var.subnet_ids) >= 2
    error_message = "The value for subnet_ids should have at least 2 subnet ids."
  }
}

variable "es_version" {
  default = "7.10"
}

variable "es_instance_type" {
  default = "r6g.large.elasticsearch"
}

variable "es_instance_count" {
  type = number
  description = "Number of elasticsearch instances"
}

variable "es_ebs_size" {
  default = "80"
}

variable "es_take_snapshot_schedule" {
  default = "cron(0 3 * * ? *)"
}

variable "es_delete_indices_schedule" {
  default = "cron(0 4 * * ? *)"
}

variable "es_kms_key_arn" {
  type = string
  validation {
    condition = length(var.es_kms_key_arn) > 0
    error_message = "The value es_kms_key_arn cannot be empty."
  }
}

variable "s3_log_bucket" {
  type = string
  validation {
    condition = length(var.s3_log_bucket) > 0
    error_message = "The value s3_log_bucket cannot be empty."
  }
}

variable "s3_kms_key_arn" {
  type = string
  validation {
    condition = length(var.s3_kms_key_arn) > 0
    error_message = "The value s3_kms_key_arn cannot be empty."
  }
}

variable "eks_cluster_admin_security_group_id" {
  type = string
  validation {
    condition = length(var.eks_cluster_admin_security_group_id) > 0
    error_message = "The value eks_cluster_worker_node_role_name cannot be empty."
  }
}
variable "eks_cluster_security_group_id" {
  type = string
  validation {
    condition = length(var.eks_cluster_security_group_id) > 0
    error_message = "The value eks_cluster_security_group_id cannot be empty."
  }
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone name for adding ES CNAME"
  type = string
  validation {
    condition = length(trimspace(var.hosted_zone_name)) > 0
    error_message = "The value hosted_zone_name cannot be empty."
  }
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone id for adding ES CNAME"
  type = string
  validation {
    condition = length(trimspace(var.hosted_zone_id)) > 0
    error_message = "The value hosted_zone_id cannot be empty."
  }
}

variable "es_snapshot_s3_bucket" {
  description = "The elasticsearch snapshot s3 bucket name."
  type = string
  validation {
    condition = length(trimspace(var.es_snapshot_s3_bucket)) > 0
    error_message = "The value es_snapshot_s3_bucket cannot be empty."
  }
}

variable "sns_topic" {
  description = "The SNS topic for failures."
}

variable "es_retention_days" {
  description = "Number of days to retain ElasticSearch indices"
}

variable "jumpbox_security_group_id" {
  type = string
}