variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name_prefix" {
  type    = string
  default = "zigi-dev"
}

# IRSA/EKS
variable "eks_cluster_name" {
  type = string
  default = "eks-angel-test"
}
variable "irsa_bucket_name" {
  type = string
  default = "bucket-name-test-angel"
}
variable "irsa_bucket_prefix" {
  type    = string
  default = "app/"
}
variable "k8s_namespace" {
  type    = string
  default = "default"
}
variable "service_account_name" {
  type    = string
  default = "api-customer"
}

# App Mesh
variable "mesh_name" {
  type    = string
  default = "zigi-mesh"
}
variable "listener_port" {
  type    = number
  default = 8080
}
variable "service_hostname" {
  type    = string
  default = "api-customer.default.svc.cluster.local"
}
variable "acm_server_cert_arn" {
  type = string
  default = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
}
variable "sds_secret_name" {
  type    = string
  default = "mesh-ca-bundle"
}

variable "trust_ca_bundle_path" {
  type    = string
  default = "/etc/ssl/certs/mesh-ca.pem"
}

# DMS + Athena
variable "dms_replication_instance_id" {
  type    = string
  default = "zigi-dms"
}
variable "dms_instance_class" {
  type    = string
  default = "dms.t3.medium"
}
variable "dms_allocated_storage_gb" {
  type    = number
  default = 50
}
variable "dms_task_id" {
  type    = string
  default = "zigi-aurora-to-s3"
}

variable "aurora_endpoint" {
  type    = string
  default = "REPLACE_ME"
}
variable "aurora_port" {
  type    = number
  default = 5432
}
variable "aurora_db_name" {
  type    = string
  default = "postgres"
}
variable "aurora_username" {
  type    = string
  default = "REPLACE_ME"
}
variable "aurora_password" {
  type      = string
  sensitive = true
  default   = "REPLACE_ME"
}

variable "datalake_bucket" {
  type    = string
  default = "replace-me-datalake"
}
variable "datalake_prefix" {
  type    = string
  default = "dms/aurora/"
}
variable "dms_s3_access_role_arn" {
  type    = string
  default = "arn:aws:iam::123456789012:role/dms-s3-access-role"
}

variable "athena_workgroup_name" {
  type    = string
  default = "zigi-wg"
}
variable "athena_results_bucket" {
  type    = string
  default = "replace-me-athena-results"
}
variable "athena_results_prefix" {
  type    = string
  default = "athena/results/"
}