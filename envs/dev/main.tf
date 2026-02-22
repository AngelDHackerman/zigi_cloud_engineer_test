terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

# Module 1: IRSA + S3 policy + ServiceAccount
module "irsa_s3" {
  source = "../../modules/irsa_s3"

  eks_cluster_name     = var.eks_cluster_name
  bucket_name          = var.irsa_bucket_name
  bucket_prefix        = var.irsa_bucket_prefix
  k8s_namespace        = var.k8s_namespace
  service_account_name = var.service_account_name
  name_prefix          = var.name_prefix
}

# Module 2: App Mesh Virtual Node + mTLS
module "appmesh_virtualnode_mtls" {
  source = "../../modules/appmesh_virtualnode_mtls"

  mesh_name           = var.mesh_name
  listener_port       = var.listener_port
  service_hostname    = var.service_hostname
  acm_server_cert_arn = var.acm_server_cert_arn

  trust_ca_bundle_path = var.trust_ca_bundle_path
}