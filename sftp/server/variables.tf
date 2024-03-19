variable "environment" {
  description = "The aws environment for the sqs queue. Eg: dev, stg, prd."
  type        = string
  validation {
    condition     = length(trimspace(var.environment)) > 0
    error_message = "The value hosted_zone_name cannot be empty."
  }
}

variable "client" {
  description = "The client name (geography based convention). Eg: ca-sk for Canada Saskatchewan."
  type        = string
  validation {
    condition     = length(trimspace(var.client)) > 0
    error_message = "The value client cannot be empty."
  }
}

variable "application" {
  description = "The application name Eg: alcyon."
  type        = string
  validation {
    condition     = length(trimspace(var.application)) > 0
    error_message = "The value application cannot be empty."
  }
}

variable "vpc_id" {
  type = string
  validation {
    condition     = length(trimspace(var.vpc_id)) > 0
    error_message = "The value hosted_zone_name cannot be empty."
  }
}
variable "subnet" {
  type = string
  validation {
    condition     = length(trimspace(var.subnet)) > 0
    error_message = "The value hosted_zone_name cannot be empty."
  }
}
variable "certificate_arn" {
  type = string
  validation {
    condition     = length(trimspace(var.certificate_arn)) > 0
    error_message = "The value hosted_zone_name cannot be empty."
  }
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone name for adding RDS CNAME"
  type        = string
  validation {
    condition     = length(trimspace(var.hosted_zone_name)) > 0
    error_message = "The value hosted_zone_name cannot be empty."
  }
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone id for adding RDS CNAME"
  type        = string
  validation {
    condition     = length(trimspace(var.hosted_zone_id)) > 0
    error_message = "The value hosted_zone_id cannot be empty."
  }
}

variable "sftp_domain" {
  description = "Domain type for SFTP"
  type        = string
  validation {
    condition = contains([
      "S3",
    "EFS"], var.sftp_domain)
    error_message = "The value for sftp_domain can be either S3 or EFS."
  }
}

variable "domain_type" {
  description = "defines if the sftp is internet facing or internal"
  type        = string
  default     = "internet-facing"
  validation {
    condition = contains([
      "internet-facing",
    "internal"], var.domain_type)
    error_message = "The value for domain_type can be either internet-facing or internal."
  }
}
