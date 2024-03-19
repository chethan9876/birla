variable "ssm_content_command" {
  description = "The command to run."
  type = string
  validation {
    condition =  length(trimspace(var.ssm_content_command)) > 0
    error_message = "The value ssm_content_command cannot be empty."
  }
}

variable "ssm_content_description" {
  description = "Description of the command to run."
  type = string
  validation {
    condition =  length(trimspace(var.ssm_content_description)) > 0
    error_message = "The value ssm_content_description cannot be empty."
  }
}

variable "ssm_association_tag" {
  description = "Tag of the target instance for ssm."
  type = string
  validation {
    condition =  length(trimspace(var.ssm_association_tag)) > 0
    error_message = "The value ssm_association_tag cannot be empty."
  }
}

variable "environment" {
  description = "The aws environment for the ssm document. Eg: dev, stg, prd."
  type = string
  validation {
    condition = length(trimspace(var.environment)) > 0
    error_message = "The value environment cannot be empty."
  }
}

variable "name" {
  description = "The ssm document name."
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