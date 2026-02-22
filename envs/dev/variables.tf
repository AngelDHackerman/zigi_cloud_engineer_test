variable "aws_region" { 
    type = string 
    default = "us-east-1" 
}

variable "name_prefix" { 
    type = string 
    default = "zigi-dev" 
}

# IRSA/EKS
variable "eks_cluster_name" { 
    type = string 
}
variable "irsa_bucket_name" { 
    type = string 
}
variable "irsa_bucket_prefix" { 
    type = string 
    default = "app/" 
}
variable "k8s_namespace" { 
    type = string 
    default = "default" 
}
variable "service_account_name" { 
    type = string 
    default = "api-customer" 
}

