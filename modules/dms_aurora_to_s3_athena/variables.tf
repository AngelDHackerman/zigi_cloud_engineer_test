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

variable "dms_replication_instance_id" {
  type        = string
  description = "ID de la instancia de replicación DMS"
  default     = "zigi-dms"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,62}$", var.dms_replication_instance_id))
    error_message = "dms_replication_instance_id debe empezar con letra y contener solo lowercase, números y guiones."
  }
}

variable "dms_instance_class" {
  type        = string
  description = "Clase de instancia DMS"
  default     = "dms.t3.medium"
  validation {
    condition     = can(regex("^dms\\.[a-z0-9]+\\.[a-z0-9]+$", var.dms_instance_class))
    error_message = "dms_instance_class debe tener formato tipo 'dms.t3.medium'."
  }
}

variable "dms_allocated_storage_gb" {
  type        = number
  description = "Storage asignado a la instancia DMS (GB)"
  default     = 50
  validation {
    condition     = var.dms_allocated_storage_gb >= 50 && var.dms_allocated_storage_gb <= 1024
    error_message = "dms_allocated_storage_gb debe estar entre 50 y 1024."
  }
}








