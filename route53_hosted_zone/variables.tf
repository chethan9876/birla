variable "environment" {
  description = "The aws environment for the sqs queue. Eg: dev, stg, prd."
  type = string
  validation {
    condition = length(trimspace(var.environment)) > 0
    error_message = "The value environment cannot be empty."
  }
}

variable "region" {
  description = "The aws region."
  type = string
  validation {
    condition = length(trimspace(var.region)) > 0
    error_message = "The value region cannot be empty."
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

variable "root_domain" {
  description = "The root domain name Eg: redflexusa.onl"
  type = string
  validation {
    condition = length(trimspace(var.root_domain)) > 0
    error_message = "The value root_domain cannot be empty."
  }
}

variable "subdomain" {
  description = "The sub domain name Eg: neo for neo.rts.onl"
  type = string
  validation {
    condition = length(trimspace(var.subdomain)) > 0
    error_message = "The value subdomain cannot be empty."
  }
}
