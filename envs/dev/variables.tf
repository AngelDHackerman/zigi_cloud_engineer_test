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

# App Mesh
variable "mesh_name" { 
    type = string 
    default = "zigi-mesh" 
}
variable "listener_port" { 
    type = number 
    default = 8080 
}
variable "service_hostname" { 
    type = string 
    default = "api-customer.default.svc.cluster.local" 
}
variable "acm_server_cert_arn" { 
    type = string 
}
variable "sds_secret_name" { 
    type = string 
    default = "mesh-ca-bundle" 
}

variable "trust_ca_bundle_path" { 
    type = string 
    default = "/etc/ssl/certs/mesh-ca.pem" 
}