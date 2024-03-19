variable "environment" {
  description = "The aws environment for the kms key. Eg: dev, stg, prd."
  type = string
  validation {
    condition = length(trimspace(var.environment)) > 0
    error_message = "The value environment cannot be empty."
  }
}

variable "application" {}

variable "client" {
  description = "The client name (geography based convention). Eg: ca-sk for Canada Saskatchewan."
  type = string
  validation {
    condition = length(trimspace(var.client)) > 0
    error_message = "The value client cannot be empty."
  }
}

variable "vpc_id" {
  description = "The VPC id for creating the endpoint."
  type = string
  validation {
    condition = length(trimspace(var.vpc_id)) > 0
    error_message = "The value vpc_id cannot be empty."
  }
}

variable "subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for the endpoint. Applicable for endpoints of type Interface"
  type = set(string)
}

variable "allowed_principals" {}

variable "certificate_arn" {}

variable "vpce_network_interface_ip_1" {}

variable "vpce_network_interface_ip_2" {}

variable "vpce_network_interface_ip_3" {}

variable "name" {}

variable "private_dns_name" {
  default = ""
}

variable "zone_id" {}