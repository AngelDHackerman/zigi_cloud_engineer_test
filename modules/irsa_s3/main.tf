data "aws_eks_cluster" "this_cluster" {
    name = var.eks_cluster_name
}

# OIDC issuer URL viene del cluster (dinámico, sin hardcode)
locals {
  oidc_issuer_url = data.aws_eks_cluster.this_cluster.identity[0].oidc[0].issuer
  oidc_issuer_hostpath = replace(local.oidc_issuer_url, "https://", "")
}