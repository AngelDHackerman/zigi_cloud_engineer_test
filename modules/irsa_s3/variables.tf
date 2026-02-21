variable "eks_cluster_name" {
    type = string
    description = "Nombre del cluster EKS"
    validation {
      condition = length(var.eks_cluster_name) > 1
      error_message = "eks_cluster_name no puede estar vacio"
    }
}