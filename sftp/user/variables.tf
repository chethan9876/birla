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

variable "service_arn" {
  type        = string
  description = "Arn of either S3 bucket to use or efs"
}

variable "service_id" {
  type        = string
  description = "ID of either S3 bucket to use or efs"
}

variable "user" {
  type    = string
  default = "user"
}

variable "home_folder" {
  type    = string
  default = ""
}

variable "sftp_server_id" {
  type = string
}

variable "posix_user_id" {
  type        = number
  description = "posix user id of the sftp user"
  default     = 1000
}

variable "posix_group_id" {
  type        = number
  description = "posix group id of the sftp user"
  default     = 1000
}

variable "secondary_group_id" {
  description = "secondary group id of the sftp user"
  default     = [1000]
}