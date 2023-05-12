# Kubernetes Cluster GItOps development environment

This repository contains the Terraform code to create a Kubernetes cluster using [Kind](https://kind.sigs.k8s.io/).
ArgoCD is installed on the cluster to manage the GitOps repositories.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.14.5
- [Kind](https://kind.sigs.k8s.io/) >= 0.18.0

## Usage

Eventually create a `terraform.tfvars` to override variables defined in `variables.tf`.

```bash
# Create a Kubernetes cluster using Terraform
cd cluster-bootstrap
terraform init
terraform apply
```

## Destroy the cluster

```bash
cd cluster-bootstrap
terraform destroy
```
