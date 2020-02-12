![Intro](./docs/ui-dashboard.png)

This project shows you how to set up the latest **Amazon Provider Kubernetes (EKS)** using Terraform

## Prerequisites

* AWS Console
* WSL, Python 3, AWS CLI
* Terraform v0.12.9+

## Install EKS

We are using Terraform with an AWS provider to install and configure EKS in your existing AWS environment. We are targeting a VPC `cidr_block = 12.0.0.0/16` in `region  = us-east-2` and a S3 Bucket named `bucket = uranus-terraform-backend` for the Terraform backend. We are also using a `scaling_config = 1` for the EKS Nodes to reduce costs.

* Clone Project

    ```
    git clone https://gitlab.com/advlab/uranus.git
    cd uranus
    ```

* Create Infrastructure

    ```
    export AWS_PROFILE=advlab; printenv AWS_PROFILE
    ```

* Initialize Terraform

    ```
    terraform init
    ```

* Create Infrastructure (or "terraform plan" first)

    ```
    terraform apply
    ```

## Install kubectl

Kubernetes uses `kubectl` to interact with the cluster and it is essential in Micoservices deployments and managing the cluster itself. 

* Install kubectl

    ```
    curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    ```

* Generate IAM Role authentication ConfigMap

    ```
    terraform output config_map_aws_auth | kubectl apply -f -
    ```

* Test EKS Cluster

    ```
    kubectl get namespaces
    kubectl cluster-info
    kubectl get node
    ```

