variable "mesh_name" {
  type = string
  default = "zigi-mesh"
}

variable "listener_port" {
  type    = number
  default = 8080
  validation {
    condition     = var.listener_port >= 1 && var.listener_port <= 65535
    error_message = "listener_port debe ser un puerto válido."
  }
}

variable "acm_server_cert_arn" {
  type        = string
  description = "ARN del cert en ACM usado para TLS en el Virtual Node"
  validation {
    condition     = can(regex("^arn:aws:acm:", var.acm_server_cert_arn))
    error_message = "acm_server_cert_arn debe ser un ARN de ACM."
  }
}
