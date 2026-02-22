variable "aws_region" { 
    type = string 
    default = "us-east-1" 
}

# IRSA/EKS
variable "eks_cluster_name" { type = string }