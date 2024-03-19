variable "sqs_kms_key_arn" {
  description = "SQS KMS Key ARN"
  type = string
  validation {
    condition = length(trimspace(var.sqs_kms_key_arn)) > 0
    error_message = "The value aws_kms_sqs_key_arn cannot be empty."
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

variable "alarm_sns_topic_arn" {
  description = "arn to be used for sending alarms"
  type = string
  validation {
    condition = length(trimspace(var.alarm_sns_topic_arn)) > 0
    error_message = "The value alarm_sns_topic_arn cannot be empty."
  }
}

variable "visibility_timeout_seconds" {
  default = 300
  type = number
  description = "Time in seconds during which sqs prevents other consumers from receiving and processing the message"
}

variable "max_receive_count"{
  default = 1
  type = number
  description = "Maximum number of items that can be enqueued"
}

variable "delay_seconds" {
  default = 3
  type = number
  description = "Delay in seconds post which item in the queue is dispatched to consumer"
}