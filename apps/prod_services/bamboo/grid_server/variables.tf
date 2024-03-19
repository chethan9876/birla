variable "region" {
  description = "AWS Region"
  default = "ap-southeast-2"
}

variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
  default = "DevKeyPair"
}

variable "key_path" {
  description = "Path to the private key .pem file"
  default = "~/.ssh/DevKeyPair.pem"
}

variable "core_os_version" {
  description = "Core OS Version"
  default = "1911.5.0"
}

variable "vpc_id" {
  description = "VPC ID to use in VPC"
  default = "vpc-80d41ee4"
}
variable "subnet_id" {
  description = "Subnet ID to use in VPC"
  default = "subnet-5ec7e03a"
}

variable "security_group_id" {
  description = "Security Group"
  default = "sg-918fd2f6"
}

variable "route53_zone_id" {
  description = "Zone ID for Route 53"
  default = "Z1TB6WCYINCPA7"
}

variable "instance_type" {
  description = "Instance type"
  default = "t2.large"
}