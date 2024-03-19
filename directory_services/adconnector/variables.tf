variable "activedirectoryname" {}
variable "adconnector_username" {}
variable "adconnector_password" {
  type        = string
  description = "adconnector account password"
  default     = null
  sensitive   = true
}
variable "vpc_id" {}
variable "adconnectorsize" {
  validation {
    condition = contains(["Large", "Small"], var.adconnectorsize)
    error_message = "The value adconnectorsize must be one of the following: Large or Small."
  }
}
variable "ad_dns" {
  type    = list(string)
}
variable "subnet_ids" {
  type    = set(string)
}

