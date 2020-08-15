#
# Variables Configuration
#

variable "cluster-name" {
  default = "terraform-eks-kubernetes"
  type    = string
}

variable "kubernetes_version" {
  default = "1.17"
  type    = string
}
