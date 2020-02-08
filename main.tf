# Setup our providers so that we have deterministic dependecy resolution. 
provider "aws" {
  region  = "${var.region}"
  version = ">= 2.38.0"
}

# Save Terraform State to S3 Bucket
terraform {
  backend "s3" {
    bucket = "gaia-terraform-backend"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

# Not required: currently used in conjuction with using
# icanhazip.com to determine local workstation external IP
# to open EC2 Security Group access to the Kubernetes cluster.
# See workstation-external-ip.tf for additional information.
#provider "http" {}

# Using these data sources allows the configuration to be
# generic for any region.
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}
