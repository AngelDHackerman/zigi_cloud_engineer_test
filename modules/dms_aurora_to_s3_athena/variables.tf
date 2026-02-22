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

variable "name_prefix" {
  type        = string
  description = "Prefijo para nombrar recursos del módulo"
  default     = "zigi"
  validation {
    condition     = length(var.name_prefix) > 0
    error_message = "name_prefix no puede estar vacío."
  }
}

variable "aurora_endpoint" {
  type        = string
  description = "Endpoint DNS de Aurora PostgreSQL (writer o reader endpoint)"
  validation {
    condition     = length(var.aurora_endpoint) > 3
    error_message = "aurora_endpoint no puede estar vacío."
  }
}

variable "aurora_port" {
  type        = number
  description = "Puerto de Aurora PostgreSQL"
  default     = 5432
  validation {
    condition     = var.aurora_port >= 1 && var.aurora_port <= 65535
    error_message = "aurora_port debe ser un puerto válido."
  }
}

variable "aurora_username" {
  type        = string
  description = "Usuario para conectarse a Aurora"
  validation {
    condition     = length(var.aurora_username) > 0
    error_message = "aurora_username no puede estar vacío."
  }
}

variable "aurora_password" {
  type        = string
  description = "Password para conectarse a Aurora (en real debería venir de Secrets Manager/SSM)"
  sensitive   = true
  validation {
    condition     = length(var.aurora_password) >= 8
    error_message = "aurora_password debe tener mínimo 8 caracteres."
  }
}

variable "aurora_db_name" {
  type        = string
  description = "Nombre de la base de datos en Aurora"
  default     = "postgres"
  validation {
    condition     = length(var.aurora_db_name) > 0
    error_message = "aurora_db_name no puede estar vacío."
  }
}

variable "datalake_bucket" {
  type        = string
  description = "Bucket S3 destino para el data lake (target de DMS)"
  validation {
    condition     = can(regex("^[a-z0-9.-]{3,63}$", var.datalake_bucket))
    error_message = "datalake_bucket debe cumplir naming rules de S3 (3-63, lowercase, digits, . y -)."
  }
}

variable "datalake_prefix" {
  type        = string
  description = "Prefix (folder) dentro del bucket para dejar los datasets replicados"
  default     = "dms/aurora/"
  validation {
    condition     = can(regex("^[a-zA-Z0-9/_-]*$", var.datalake_prefix))
    error_message = "datalake_prefix solo puede contener letras, números, /, _, -."
  }
}

variable "dms_s3_access_role_arn" {
  type        = string
  description = "IAM Role ARN que DMS usa para escribir en S3"
  default     = "arn:aws:iam::123456789012:role/dms-s3-access-role"
}







