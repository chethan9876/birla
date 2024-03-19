variable "environment" {
  description = "The aws environment for the sqs queue. Eg: dev, stg, prd."
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

variable "application" {
  description = "The application name Eg: alcyon."
  type = string
  validation {
    condition = length(trimspace(var.application)) > 0
    error_message = "The value application cannot be empty."
  }
}

variable "vpc_id" {
  description = "VPC ID"
  type = string
  validation {
    condition = length(trimspace(var.vpc_id)) > 0
    error_message = "The value vpc_id cannot be empty."
  }
}

variable "db_name" {
  description = "DB name"
  type = string
  validation {
    condition = length(trimspace(var.db_name)) > 0
    error_message = "The value db_name cannot be empty."
  }
}

variable "db_engine_version" {
  description = "DB Engine Version"
  type = string
  validation {
    condition = length(trimspace(var.db_engine_version)) > 0
    error_message = "The value engine_version cannot be empty."
  }
}

variable "db_snapshot_identifier" {
  description = "DB Snapshot ID"
  type = string
}

variable "db_kms_key_arn" {
  description = "DB KMS Key ARN"
  type = string
  validation {
    condition = length(trimspace(var.db_kms_key_arn)) > 0
    error_message = "The value db_kms_key_arn cannot be empty."
  }
}

variable "db_subnet_group_name" {
  description = "DB Subnet Group Name"
  type = string
  validation {
    condition = length(trimspace(var.db_subnet_group_name)) > 0
    error_message = "The value db_subnet_group_name cannot be empty."
  }
}

variable "db_cluster_parameter_group_family" {
  description = "DB Param Group Family"
  type = string
  validation {
    condition = length(trimspace(var.db_cluster_parameter_group_family)) > 0
    error_message = "The value db_cluster_parameter_group_family cannot be empty."
  }
}

variable "db_instance_count" {
  description = "Number of instances in the cluster"
  type = number
  default = 2
}

variable "db_performance_insights_enabled" {
  default = true
}

variable "instance_class" {
  description = "DB instance class"
  type = string
  default = "db.r6g.xlarge"
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone name for adding RDS CNAME"
  type = string
  validation {
    condition = length(trimspace(var.hosted_zone_name)) > 0
    error_message = "The value hosted_zone_name cannot be empty."
  }
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone id for adding RDS CNAME"
  type = string
  validation {
    condition = length(trimspace(var.hosted_zone_id)) > 0
    error_message = "The value hosted_zone_id cannot be empty."
  }
}