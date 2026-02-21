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

  statement {
    sid     = "S3ReadWriteObjects"
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["arn:aws:s3:::${var.bucket_name}/${var.bucket_prefix}*"]
  }
}

resource "aws_iam_policy" "this_cluster" {
  name   = "${var.name_prefix}-s3-min"
  policy = data.aws_iam_policy_document.s3_min_policy.json
}

# Trust relationship IRSA (sub + aud) usando provider OIDC descubierto
data "aws_iam_policy_document" "irsa_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.this_cluster.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:sub"
      values   = ["system:serviceaccount:${var.k8s_namespace}:${var.service_account_name}"]
    }

  }
}

resource "aws_iam_role" "this_cluster" {
  name               = "${var.name_prefix}-irsa"
  assume_role_policy = data.aws_iam_policy_document.irsa_trust.json
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.this_cluster.name
  policy_arn = aws_iam_policy.this_cluster.arn
}