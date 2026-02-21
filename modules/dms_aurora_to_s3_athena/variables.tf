variable "athena_results_bucket" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9.-]{3,63}$", var.athena_results_bucket))
    error_message = "athena_results_bucket inválido."
  }
}

variable "athena_workgroup_name" {
  type    = string
  default = "zigi-wg"
}

variable "athena_results_prefix" {
  type        = string
  description = "Prefijo (folder) dentro del bucket para guardar resultados de Athena (ej: athena/results/)"
  default     = "athena/results/"

  validation {
    condition     = can(regex("^[a-zA-Z0-9/_-]*$", var.athena_results_prefix))
    error_message = "athena_results_prefix solo puede contener letras, números, /, _, -."
  }
}