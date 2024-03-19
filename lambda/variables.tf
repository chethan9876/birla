variable "vpc_id" {type=string}

variable "filename" {
  type = string
  description = "zip file containing lambda source code"
}

variable "function_name" {
  type = string
  description = "Name of the lambda function"
}

variable "environment_args" {
  type    = map(string)
  default = null
}

variable "role" {
  type = string
  description = "Role required by lambda to access various resources"
}

variable "handler" {
  type = string
  description = "Name of the handler method"
}

variable "source_hash" {
  type = string
  description = "Source doe hash"
}

variable "runtime" {
  type = string
  description = "Runtime for the lambda function"
}

variable "application" {
  type = string
  description = "Name of the application applicable for this lambda"
}

variable "environment" {
  type = string
  description = "Deployment environment"
}

variable "client" {
  type = string
}

variable "subnet_ids" {
  description = "App Subnet IDs across different Availability Zones in the region"
  type = set(string)
  validation {
    condition = length(var.subnet_ids) >= 2
    error_message = "The value for subnet_ids should have at least 2 subnet ids."
  }
}

variable "sns_topic" {
  type = string
  default = ""
}

variable "statement" {
  type = string
}
variable "action" {
  type = string
  default = "lambda:InvokeFunction"
}
variable "principal" {
  type = string
}
variable "source_arn" {
  type = string
}

variable "timeout" {
  type = number
  default = 600
}

variable "memory_size" {
  type = number
  default = 128
}