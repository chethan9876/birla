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

variable "vpc_id" {}

variable "subnet_ids" {
  description = "App Subnet IDs across different Availability Zones in the region"
  type = set(string)
  validation {
    condition = length(var.subnet_ids) >= 2
    error_message = "The value for subnet_ids should have at least 2 subnet ids."
  }
}

variable "internal_route_table_id" {
  description = "The id of the route table for internal subnets."
  type = string
  validation {
    condition = length(trimspace(var.internal_route_table_id)) > 0
    error_message = "The value internal_route_table_id cannot be empty."
  }
}

variable "security_account_cloudtrail_bucket" {
  description = "S3 bucket in Security AWS account where cloudtrail logs from all accounts are exported"
  type = string
  default = "redflexsec-cloudtrail-logs"
}

variable "pagerduty_integration_key" {
  description = "The Pagerduty integration key"
  type = string
  validation {
    condition = length(trimspace(var.pagerduty_integration_key)) > 0
    error_message = "The value pagerduty_integration_key cannot be empty."
  }
}
