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

variable "eks_version" {
  description = "The EKS cluster version."
  type = string
  default = null
}

variable "vpc_id" {
  description = "The VPC id for creating the EKS cluster."
  type = string
  validation {
    condition = length(trimspace(var.vpc_id)) > 0
    error_message = "The value vpc_id cannot be empty."
  }
}

variable "subnet_ids" {
  description = "The subnet ids for running the EKS cluster."
  type = list(string)
  validation {
    condition = length(var.subnet_ids) >= 2
    error_message = "EKS requires subnets in at least two Availability Zones."
  }
}

variable "secure_node_subnet_ids" {
  description = "The subnet ids for running the pods that require connectivity to Secure DMV data from EKS cluster."
  type = list(string)
  default = []
}

variable "approach_node_subnet_ids" {
  description = "The subnet ids for running the pod that require connectivity to approaches from EKS cluster."
  type = list(string)
  default = []
}

variable "dmz_ids" {
  description = "The dmz subnet ids."
  type = list(string)
  validation {
    condition = length(var.dmz_ids) >= 2
    error_message = "The value dmz_ids should be greater than or equal to 2."
  }
}

variable "cluster_worker_node_instance_type" {
  description = "The instance type for the worker nodes in the EKS cluster."
  type = string
  validation {
    condition = length(trimspace(var.cluster_worker_node_instance_type)) > 0
    error_message = "The value cluster_worker_node_instance_type cannot be empty."
  }
  default = "m5.2xlarge"
}

variable "cluster_worker_node_ssh_key" {
  description = "The SSH keypair name for accessing the worker nodes in the EKS cluster."
  type = string
  validation {
    condition = length(trimspace(var.cluster_worker_node_ssh_key)) > 0
    error_message = "The value cluster_worker_node_ssh_key cannot be empty."
  }
}

variable "cluster_worker_node_autoscaling_desired_size" {
  description = "The desired number of worker nodes to launch with initially."
  type = number
  validation {
    condition  = var.cluster_worker_node_autoscaling_desired_size >= 0
    error_message = "The value cluster_worker_node_autoscaling_desired_size should be greater than or equal to 0."
  }
  default = 2
}

variable "cluster_worker_node_autoscaling_min_size" {
  description = "The minimum number of worker nodes to scale in to."
  type = number
  validation {
    condition  = var.cluster_worker_node_autoscaling_min_size >= 0
    error_message = "The value cluster_worker_node_autoscaling_min_size should be greater than or equal to 0."
  }
  default = 2
}

variable "cluster_worker_node_autoscaling_max_size" {
  description = "The maximum number of worker nodes to scale out to."
  type = number
  validation {
    condition  = var.cluster_worker_node_autoscaling_max_size >= 1
    error_message = "The value cluster_worker_node_autoscaling_max_size should be greater than or equal to 1."
  }
  default = 2
}

variable "cluster_worker_node_disk_size" {
  description = "The disk size in GB for worker nodes."
  type = number
  validation {
    condition  = var.cluster_worker_node_disk_size >= 80
    error_message = "The value cluster_worker_node_disk_size should be greater than or equal to 80."
  }
  default = 80
}

variable "cluster_admin_instance_type" {
  description = "The instance type for the cluster admin used for managing the EKS cluster."
  type = string
  validation {
    condition = length(trimspace(var.cluster_admin_instance_type)) > 0
    error_message = "The value cluster_admin_instance_type cannot be empty."
  }
  default = "t3.small"
}

variable "cluster_admin_ami" {
  description = "The ami for the cluster admin used for managing the EKS cluster."
  type = string
  validation {
    condition = length(trimspace(var.cluster_admin_ami)) > 0
    error_message = "The value cluster_admin_ami cannot be empty."
  }
}

variable "cluster_admin_disk_size" {
  description = "The disk size in GB for the cluster admin."
  type = number
  validation {
    condition  = var.cluster_admin_disk_size >= 40
    error_message = "The value cluster_admin_disk_size should be greater than or equal to 40."
  }
  default = 40
}

variable "jumpbox_ingress_security_group_id" {
  description = "Jumpbox security group id that requires access to cluster admin instance"
  type = string
}

variable "docker_registry_domain" {
  description = "The custom domain for docker registry."
  type = string
  validation {
    condition = length(trimspace(var.docker_registry_domain)) > 0
    error_message = "The value docker_registry_domain cannot be empty."
  }
  default = "dockerp.rtsprod.net"
}

variable "efs_dns_name" {
  description = "The DNS name for common EFS instance"
  type = string
  validation {
    condition = length(trimspace(var.efs_dns_name)) > 0
    error_message = "The value efs_dns_name cannot be empty."
  }
}

variable "root_domain" {
  description = "The root domain name. Eg: redflexcalgary.onl."
  type = string
  validation {
    condition = length(trimspace(var.root_domain)) > 0
    error_message = "The value root_domain cannot be empty."
  }
}

variable "hosted_zone_name" {
  description = "The hosted zone to be used for creating DNS record for cluster admin. Eg: neo.rts.onl."
  type = string
  validation {
    condition = length(trimspace(var.hosted_zone_name)) > 0
    error_message = "The value route53_zone cannot be empty."
  }
}

variable "hosted_zone_id" {
  description = "The hosted zone ID to be used for creating DNS record for cluster admin. Eg: neo.rts.onl."
  type = string
  validation {
    condition = length(trimspace(var.hosted_zone_id)) > 0
    error_message = "The value hosted_zone_id cannot be empty."
  }
}

variable "hosted_zone_arn" {
  description = "The hosted zone arn to be used for creating DNS record for cluster admin. Eg: neo.rts.onl."
  type = string
  validation {
    condition = length(trimspace(var.hosted_zone_arn)) > 0
    error_message = "The value hosted_zone_arn cannot be empty."
  }
}

variable "efs_file_system_security_group_id" {
  description = "The Route53 zone to be used for creating DNS record for cluster admin. Eg: neo.rts.onl."
  type = string
  validation {
    condition = length(trimspace(var.efs_file_system_security_group_id)) > 0
    error_message = "The value efs_file_system_security_group_id cannot be empty."
  }
}

variable "workspace_ip_ranges" {
  description = "List of subnet ranges used by workspaces"
  default = null
}

variable "sns_topic" {
  type = string
  default = ""
}

variable "pega_layer" {}

variable "additional_user_data" {
  default = ""
}