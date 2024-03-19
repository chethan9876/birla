variable "rest_api_id" {}
variable "vpc_link_id" {}
variable "parent_resource_id" {}
variable "integration_url" {}
variable "authorisation" {}
variable "path" {}
variable "http_method" {
  default = "POST"
}
variable "integration_type" {
  default = "AWS"
}
variable "region" {}
variable "queue_name" {}
variable "role_arn" {}