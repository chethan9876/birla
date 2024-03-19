variable "region" {}
variable "environment" {}
variable "client" {}
variable "profile" {}
variable "iam_arn_prefix" {
  description = "The IAM ARN prefix. Eg: arn:aws, arn:aws-us-gov."
  type = string
  validation {
    condition = contains([
      "arn:aws",
      "arn:aws-us-gov"
    ], var.iam_arn_prefix)
    error_message = "The value iam_arn_prefix must be one of the following: arn:aws, arn:aws-us-gov."
  }
  default = "arn:aws"
}


