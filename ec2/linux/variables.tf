variable "client" {}
variable "environment" {}
variable "region" {}
variable "ec2_description" {}
variable "ec2_securitygroups" {
  type = list(string)
  default = null
}
variable "linux_ami" {
  default = ["*c99b61c0-574b-4575-92fd-e8b4c943e32b"]
  type = list(string)
}
variable "iam_arn_prefix" {
  default = "arn:aws"
}
variable "instance_type" {
  default = "t3.micro"
}
variable "image_id" {
  default = ""
}
variable "key_name" {
  default = ""
}
variable "subnet_id" {}
variable "associate_public_ip_address" {
  default = "false"
}
variable "disable_api_termination" {
  default = "false"
}
variable "monitoring" {
  default = "true"
}
variable "ebs_optimized" {
  default = "true"
}
variable "root_block_device" {
  default = "30"
}
variable "cpu_credits" {
  default = "unlimited"
}
variable "vpc_id" {}

variable "additional_user_data" {
  default = ""
}

variable "sns_topic" {
  type = string
  default = ""
}
