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

variable "database_subnet_ids" {
  description = "Database Subnet IDs"
  type = list(string)
  validation {
    condition = length(var.database_subnet_ids) > 0
    error_message = "The value database_subnet_ids cannot be empty."
  }
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

variable "elasticache_engine_version" {
  description = "ElastiCache Engine Version"
  type = string
  validation {
    condition = length(trimspace(var.elasticache_engine_version)) > 0
    error_message = "The value engine_version cannot be empty."
  }
}

variable "elasticache_snapshot_identifier" {
  description = "ElastiCache Snapshot ID"
  type = string
}

variable "elasticache_replica_count" {
  description = "Number of replicas in the cluster"
  type = number
  default = 2
}

variable "elasticache_param_group_family" {
  description = "ElastiCache param group family"
  type = string
  validation {
    condition = length(trimspace(var.elasticache_param_group_family)) > 0
    error_message = "The value elasticache_param_group_family cannot be empty."
  }
}

variable "elasticache_node_type" {
  description = "ElastiCache size of the instance"
  type = string
  default = "cache.t2.small"
}

variable "sns_topic" {
  type = string
  default = ""
}