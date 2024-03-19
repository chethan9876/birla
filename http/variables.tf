variable "vpc_id" {}
variable "vpc_internal_cidr" {}
variable "client" {}
variable "environment" {}
variable "application" {}
variable "domain" {}
variable "certificate_arn" {}
variable "hosted_zone_id" {}
variable "region" {}
variable "whitelist_ips" {
  default = ["0.0.0.0/0"]
}