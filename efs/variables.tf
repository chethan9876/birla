variable "environment" {
  description = "The aws environment for the efs. Eg: dev, stg, prd."
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

variable "transition_to_ia" {
  description = "Indicates how long it takes to transition files to the IA storage class."
  type = string
  validation {
    condition = contains([
      "AFTER_7_DAYS",
      "AFTER_14_DAYS",
      "AFTER_30_DAYS",
      "AFTER_60_DAYS",
      "AFTER_90_DAYS"], var.transition_to_ia)
    error_message = "The value transition_to_ia must be one of the following: AFTER_7_DAYS, AFTER_14_DAYS, AFTER_30_DAYS, AFTER_60_DAYS, or AFTER_90_DAYS."
  }
  default = "AFTER_14_DAYS"
}

variable "kms_key_id" {
  description = "The KMS key id for encrypting the EFS file system."
  type = string
  validation {
    condition = length(trimspace(var.kms_key_id)) > 0
    error_message = "The value kms_key_id cannot be empty."
  }
}

variable "provisioned_throughput_in_mibps" {
  description = "Provisioned throughput capacity"
  type = number
  validation {
    condition = var.provisioned_throughput_in_mibps > 0
    error_message = "The value provisioned_throughput_in_mibps cannot be zero."
  }
  default = 5
}

variable "mount_targets" {
  description = "The subnet ids to be used as efs mount targets."
  type = list(string)
  validation {
    condition = length(var.mount_targets) > 1
    error_message = "The value mount_targets should have more than one value."
  }
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone name for adding EFS CNAME"
  type = string
  validation {
    condition = length(trimspace(var.hosted_zone_name)) > 0
    error_message = "The value hosted_zone_name cannot be empty."
  }
}
variable "hosted_zone_id" {
  description = "Route53 hosted zone id for adding EFS CNAME"
  type = string
  validation {
    condition = length(trimspace(var.hosted_zone_id)) > 0
    error_message = "The value hosted_zone_id cannot be empty."
  }
}