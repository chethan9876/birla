variable "region" {}
variable "environment" {}
variable "client" {}
variable "profile" {}
variable "key_pair_name" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}

variable "instance_type" {
  default = "t3.medium"
}

variable "domaincontroller_ami" {}

variable "domaincontroller_ssh_key" {
  description = "The SSH keypair name for accessing the domain controller."
  type = string
  validation {
    condition = length(trimspace(var.domaincontroller_ssh_key)) > 0
    error_message = "The value domaincontroller_ssh_key cannot be empty."
  }
}

variable "domaincontroller_disk_size" {
  description = "The disk size in GB for the Domain Controller."
  type = number
  validation {
    condition  = var.domaincontroller_disk_size >= 100
    error_message = "The value domaincontroller_disk_size should be greater than or equal to 100."
  }
  default = 100
}

variable "domaincontroller_securitygroup_ingress_ports" {type = list(object({
  protocol = string
  cidr_blocks = list(string)
  from_port = number
  to_port = number
  security_groups = list(string)
  description = string

}))}

variable "domaincontroller_securitygroup_egress_ports" {type = list(object({
  protocol = string
  cidr_blocks = list(string)
  from_port = number
  to_port = number
  security_groups = list(string)
  description = string

}))}

variable "crowd_strike_sg_id" {}