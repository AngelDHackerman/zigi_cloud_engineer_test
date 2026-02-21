variable "athena_results_bucket" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9.-]{3,63}$", var.athena_results_bucket))
    error_message = "athena_results_bucket inválido."
  }
}
