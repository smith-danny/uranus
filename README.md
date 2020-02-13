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

* Create kubectl configuration for EKS

    ```
    terraform output kubeconfig > ~/.kube/config
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

## Deploy helloworld

* Deploy App

    ```
    cat <<EOF | kubectl apply -f -
    ---
    apiVersion: extensions/v1beta1
    kind: Deployment
    metadata:
    name: helloworld-deployment
    labels:
        app: helloworld
    spec:
    replicas: 1
    template:
        metadata:
        labels:
            app: helloworld
        spec:
        containers:
        - name: helloworld
            image: dockercloud/hello-world
            ports:
            - containerPort: 80
    ---
    apiVersion: v1
    kind: Service
    metadata:
    name: "service-helloworld"
    spec:
    selector:
        app: helloworld
    type: LoadBalancer
    ports:
    - protocol: TCP
        port: 80
        targetPort: 80
    EOF
    ```

* Get App info

    ```
    kubectl get svc service-helloworld -o yaml
    ```

* Browse to the `hostname`

## Deploy NGINX app and test BASH access

* Deploy App

    ```
    cat <<EOF | kubectl apply -f -
    ---
    apiVersion: v1
    kind: Pod
    metadata:
    name: shell-demo
    spec:
    volumes:
    - name: shared-data
        emptyDir: {}
    containers:
    - name: nginx
        image: nginx
        volumeMounts:
        - name: shared-data
        mountPath: /usr/share/nginx/html
    hostNetwork: true
    dnsPolicy: Default
    EOF
    ```

* Bash into App

    ```
    kubectl exec -it shell-demo -- /bin/bash
    ```
## Deploy Metrics Server

The Metrics Service the Kubernetes dashboard uses behind the scenes is based on a slimmed-down version of Heapster which needs to be installed on the cluster. 

* Download Metrics Server

    ```
    cd ~
    DOWNLOAD_URL=$(curl -Ls "https://api.github.com/repos/kubernetes-sigs/metrics-server/releases/latest" | jq -r .tarball_url)
    DOWNLOAD_VERSION=$(grep -o '[^/v]*$' <<< $DOWNLOAD_URL)
    curl -Ls $DOWNLOAD_URL -o metrics-server-$DOWNLOAD_VERSION.tar.gz
    mkdir metrics-server-$DOWNLOAD_VERSION
    tar -xzf metrics-server-$DOWNLOAD_VERSION.tar.gz --directory metrics-server-$DOWNLOAD_VERSION --strip-components 1
    kubectl apply -f metrics-server-$DOWNLOAD_VERSION/deploy/1.8+/
    ```

* Patch Deployment to use Internal IPs and accept self-signed certificates

    ```
    kubectl -n kube-system patch deployment metrics-server -p \
    '{"spec":{"template":{"spec":{"containers":[{"name":"metrics-server","command":["/metrics-server","--kubelet-preferred-address-types=InternalIP","--kubelet-insecure-tls"]}]}}}}'
    ```

* Deploy Kubernetes Dashboard (uses latest `v2.0.0-rc5` version)

    ```
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc5/aio/deploy/recommended.yaml
    ```

* Deploy `eks-admin` Service Account and Cluster Role Binding

    ```
    cat <<EOF | kubectl apply -f -
    ---
    apiVersion: v1
    kind: ServiceAccount
    metadata:
    name: eks-admin
    namespace: kube-system
    ---
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
    name: eks-admin
    roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: cluster-admin
    subjects:
    - kind: ServiceAccount
    name: eks-admin
    namespace: kube-system
    EOF
    ```

* Get a Login *Token*

    ```
    kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
    ```

* Start the Proxy

    Access to the Kubernetes cluster administration features requires the use of a proxy provided by `kubectl`

    ```
    kubectl proxy
    ```

* Browse to the Dashboard URL

    * [Dashboard URL](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/overview?namespace=default)


* Paste the *Token* obtained above to login to the Dashboard
