data "aws_eks_cluster" "this_cluster" {
    name = var.eks_cluster_name
}

# OIDC issuer URL viene del cluster (dinámico, sin hardcode)
locals {
  oidc_issuer_url = data.aws_eks_cluster.this_cluster.identity[0].oidc[0].issuer
  oidc_issuer_hostpath = replace(local.oidc_issuer_url, "https://", "")
}

# Descubre el proveedor OIDC existente por su URL (sin harcodear el ARN)
data "aws_iam_openid_connect_provider" "this_cluster" {
  url = local.oidc_issuer_hostpath
}

data "aws_iam_policy_document" "s3_min_policy" {
  statement {
    sid = "S3ListBucket"
    effect = "Allow"
    actions = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.bucket_name}"]
  }
}