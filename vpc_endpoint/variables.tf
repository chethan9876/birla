variable "region" {
  description = "The aws region."
  type = string
  validation {
    condition = length(trimspace(var.region)) > 0
    error_message = "The value region cannot be empty."
  }
}
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

variable "service_name" {
  description = "The service name for which the endpoint needs to be created."
  type = string
  validation {
    condition = length(trimspace(var.service_name)) > 0
    error_message = "The value service_name cannot be empty."
  }
}

variable "endpoint_type" {
  description = "The service name for which the endpoint needs to be created."
  type = string
  validation {
    condition = contains([
      "Gateway",
      "Interface"], var.endpoint_type)
    error_message = "The value endpoint_type must be one of the following: Gateway, Interface."
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

//TODO: Review this latere
//variable "security_group_ids" {
//  description = "The id of one or more security groups to associate with the network interface of the interface endpoint."
//  type = set(string)
//  default = []
//}

variable "subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for the endpoint. Applicable for endpoints of type Interface"
  type = set(string)
  default = []
}

variable "route_table_ids" {
  description = "One or more route table IDs. Applicable for endpoints of type Gateway."
  type = set(string)
  default = []
}