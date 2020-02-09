#
# Variables Configuration
#

variable "cluster-name" {
  type    = "string"
  default = "k8s"  
  description = "Kubernetes cluster name"
}

variable "region" {
  description = "Region to deploy the cluster into"
  default = "us-east-2"
}