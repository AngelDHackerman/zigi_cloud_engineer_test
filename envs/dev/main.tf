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

# Module 3: DMS Aurora -> S3 + Athena Workgroup
module "dms_aurora_to_s3_athena" {
  source = "../../modules/dms_aurora_to_s3_athena"

  name_prefix = var.name_prefix

  # DMS Instance
  dms_replication_instance_id = var.dms_replication_instance_id
  dms_instance_class          = var.dms_instance_class
  dms_allocated_storage_gb    = var.dms_allocated_storage_gb
  dms_task_id                 = var.dms_task_id

  # Aurora source
  aurora_endpoint = var.aurora_endpoint
  aurora_port     = var.aurora_port
  aurora_db_name  = var.aurora_db_name
  aurora_username = var.aurora_username
  aurora_password = var.aurora_password

  # S3 target
  datalake_bucket        = var.datalake_bucket
  datalake_prefix        = var.datalake_prefix
  dms_s3_access_role_arn = var.dms_s3_access_role_arn

  # Athena
  athena_workgroup_name = var.athena_workgroup_name
  athena_results_bucket = var.athena_results_bucket
  athena_results_prefix = var.athena_results_prefix
}