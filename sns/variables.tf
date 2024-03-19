variable "environment" {
  description = "The aws environment for the sns topic. Eg: dev, stg, prd."
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

variable "name" {
  description = "The sns topic name. Eg: incoming-file-events-alarm, etc."
  type = string
  validation {
    condition = length(trimspace(var.name)) > 0
    error_message = "The value name cannot be empty."
  }
}

variable "kms_key_id" {
  description = "The KMS key id for encrypting the messages in the SNS topic."
  type = string
  validation {
    condition = length(trimspace(var.kms_key_id)) > 0
    error_message = "The value kms_key_id cannot be empty."
  }
}

variable "feedback_role_arn" {
  description = "The role arn for logging success and failure message delivery statuses to CloudWatch Logs."
  type = string
  validation {
    condition = length(trimspace(var.feedback_role_arn)) > 0
    error_message = "The value feedback_role_arn cannot be empty."
  }
}