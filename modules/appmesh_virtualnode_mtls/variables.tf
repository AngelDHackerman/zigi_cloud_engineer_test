variable "mesh_name" {
  type    = string
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
variable "trust_ca_bundle_path" {
  type        = string
  description = "Ruta al bundle PEM de la CA que Envoy usará para validar mTLS (ej: /etc/ssl/certs/mesh-ca.pem)"
  default     = "/etc/ssl/certs/mesh-ca.pem"
}

variable "service_hostname" {
  type        = string
  description = "DNS name del servicio (service discovery) dentro del cluster"
  default     = "api-customer.default.svc.cluster.local"
}

