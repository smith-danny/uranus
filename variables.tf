#
# Variables Configuration
#

variable "account_id" {
  type        = string
  description = "Account ID containing IAM users to be mapped into the cluster"
}

variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "List of 2 availability zones in which to create the worker nodes"
}

variable "cluster_name" {
  type        = string
  default     = "k8s"
  description = "Kubernetes cluster name"
}

variable "role_arn" {
  type        = string
  description = "IAM role to be used when accessing the cluster"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of tags to be applied to all resources"
}

variable "region" {
  description = "Region to deploy the cluster into"
  default = "us-east-2"
}

