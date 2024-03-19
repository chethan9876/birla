variable "environment" {
  description = "The aws environment for the kms key. Eg: dev, stg, prd."
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

variable "domain_name" {
  description = "The domain name for which the certificate should be issued."
  type = string
  validation {
    condition = length(trimspace(var.domain_name)) > 0
    error_message = "The value domain_name cannot be empty."
  }
}

variable "hosted_zone_id" {
  description = "The Route53 hosted zone id used for DNS based validation of the ACM certificate."
  type = string
  validation {
    condition = length(trimspace(var.hosted_zone_id)) > 0
    error_message = "The value hosted_zone_id cannot be empty."
  }
}