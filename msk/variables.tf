variable "msk_version" {
  description = "The MSK cluster version."
  type = string
  default = "2.8.0"
  validation {
    condition = length(trimspace(var.msk_version)) > 0
    error_message = "The value msk_version cannot be empty."
  }
}

variable "msk_instance_type" {
  default = "kafka.m5.large"
  description = "MSK Instance Type"
  type = string
  validation {
    condition = length(trimspace(var.msk_instance_type)) > 0
    error_message = "The value msk_instance_type cannot be empty."
  }
}

variable "msk_broker_count" {
  default = 3
  description = "MSK Broker Count"
  type = number
  validation {
    condition = var.msk_broker_count > 0
    error_message = "The value msk_broker_count must be a positive integer."
  }
}

variable "msk_ebs_size" {
  default = 1000
  description = "MSK EBS Volume Size in GB"
  type = number
  validation {
    condition = var.msk_ebs_size > 0
    error_message = "The value msk_ebs_size must be a positive integer."
  }
}

variable "msk_kms_key_arn" {
  description = "MSK KMS Key ARN"
  type = string
  validation {
    condition = length(trimspace(var.msk_kms_key_arn)) > 0
    error_message = "The value msk_kms_key_arn cannot be empty."
  }
}

variable "subnet_ids" {
  description = "The subnet ids for running the MSK cluster."
  type = list(string)
  validation {
    condition = length(var.subnet_ids) >= 3
    error_message = "MSK requires subnets in at least three Availability Zones."
  }
}

variable "environment" {
  description = "The aws environment for the sqs queue. Eg: dev, stg, prd."
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

variable "vpc_id" {
  description = "VPC ID"
  type = string
  validation {
    condition = length(trimspace(var.vpc_id)) > 0
    error_message = "The value vpc_id cannot be empty."
  }
}

variable "sns_topic" {
  type = string
  default = ""
}