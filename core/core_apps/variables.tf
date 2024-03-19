variable "region" {
  description = "The aws region."
  type        = string
  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "The value region cannot be empty."
  }
}
variable "environment" {
  description = "The aws environment. Eg: dev, stg, prd."
  type        = string
  validation {
    condition = length(trimspace(var.environment)) > 0
    error_message = "The value environment cannot be empty."
  }
}
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
variable "client" {
  description = "The client name (geography based convention). Eg: ca-sk for Canada Saskatchewan."
  type        = string
  validation {
    condition     = length(trimspace(var.client)) > 0
    error_message = "The value client cannot be empty."
  }
}

variable "vpc_id" {}
variable "db_subnet_ids" {
  description = "DB Subnet IDs across different Availability Zones in the region"
  type        = set(string)
  validation {
    condition     = length(var.db_subnet_ids) >= 2
    error_message = "The value for db_subnet_ids should have at least 2 subnet ids."
  }
}

variable "subnet_ids" {
  description = "App Subnet IDs across different Availability Zones in the region"
  type        = set(string)
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "The value for subnet_ids should have at least 2 subnet ids."
  }
}

variable "dmz_ids" {
  description = "The dmz subnet ids."
  type        = set(string)
  validation {
    condition     = length(var.dmz_ids) >= 2
    error_message = "The value dmz_ids should be greater than or equal to 2."
  }
}

variable "secure_node_subnet_ids" {
  description = "The secure subnet ids."
  type        = set(string)
}

variable "approach_node_subnet_ids" {
  description = "The approach subnet ids."
  type        = set(string)
}

variable "eks_cluster_admin_ami" {}
variable "eks_cluster_worker_node_ssh_key" {}
variable "eks_version" {}
variable "cluster_worker_node_autoscaling_desired_size" {
  description = "The desired number of main worker nodes in main group in the cluster"
  default = 2
  type = number
}
variable "cluster_worker_node_autoscaling_min_size" {
  description = "The minimum number of worker nodes in main group in the cluster"
  default = 2
  type = number
}
variable "cluster_worker_node_autoscaling_max_size" {
  description = "The maximum number of worker nodes in main group in the cluster"
  default = 2
  type = number
}

variable "root_domain" {}
variable "subdomain" {}

variable "s3_log_bucket" {
  type = string
  validation {
    condition     = length(var.s3_log_bucket) > 0
    error_message = "The value s3_log_bucket cannot be empty."
  }
}

variable "s3_kms_key_arn" {
  type = string
  validation {
    condition     = length(var.s3_kms_key_arn) > 0
    error_message = "The value s3_kms_key_arn cannot be empty."
  }
}

variable "es_instance_count" {
  type = number
  default = 2
  validation {
    condition     = var.es_instance_count >= 2
    error_message = "The value for es_instance_count should at least be 2."
  }
}

variable "workspace_ip_ranges" {
  default = null
}

variable "sns_topic" {
  type = string
}

variable "es_retention_days" {
  type = string
}

variable "jumpbox_ssh_key" {
  type = string
}

variable "pega_layer" {}

variable "additional_user_data" {
  default = ""
}

variable "jumpbox_allowed_cidr" {
  default = ["216.161.174.141/32",
    "216.161.174.142/32",
    "103.87.254.138/32",
    "72.44.238.12/32",
    "72.44.255.49/32",
    "15.206.230.67/32",
    "5.2.19.94/32"]
}