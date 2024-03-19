variable "region" {}
variable "environment" {}
variable "client" {}
variable "profile" {}
variable "key_pair_name" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}

variable "itservice_instance_type" {
  default = "t3.medium"
}

variable "itservice_ami" {}

variable "itservice_ssh_key" {
  description = "The SSH keypair name for accessing the IT Services server."
  type = string
  validation {
    condition = length(trimspace(var.itservice_ssh_key)) > 0
    error_message = "The value itservice_ssh_key cannot be empty."
  }
}

variable "itservice_disk_size" {
  description = "The disk size in GB for the Domain Controller."
  type = number
  validation {
    condition  = var.itservice_disk_size >= 100
    error_message = "The value itservice_disk_size should be greater than or equal to 100."
  }
  default = 100
}

variable "itservice_securitygroup_ingress_ports" {type = list(object({
  protocol = string
  cidr_blocks = list(string)
  from_port = number
  to_port = number
  security_groups = list(string)
  description = string

}))}

variable "itservice_securitygroup_egress_ports" {type = list(object({
  protocol = string
  cidr_blocks = list(string)
  from_port = number
  to_port = number
  security_groups = list(string)
  description = string

}))}