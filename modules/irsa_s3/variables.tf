variable "eks_cluster_name" {
    type = string
    description = "Nombre del cluster EKS"
    validation {
      condition = length(var.eks_cluster_name) > 1
      error_message = "eks_cluster_name no puede estar vacio"
    }
}

variable "bucket_name" {
  type = string
  description = "Bucket S3 destino"
  validation {
    condition = can(regex("^[a-z0-9.-]{3,63}$", var.bucket_name))
    error_message = "bucket_name debe cumplir naming rules de S3 (3-63, lowercase, digits, . , -)."
  }
}

variable "bucket_prefix" {
  type        = string
  description = "Prefix dentro del bucket para limitar permisos"
  default     = "app/"
}