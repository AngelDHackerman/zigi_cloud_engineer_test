resource "aws_s3_bucket" "athena_results" {
  bucket = var.athena_results_bucket
  # Force destroy para limpieza del bucket cuando sea necesario
  force_destroy = true
}

resource "aws_athena_workgroup" "this_dms" {
  name = var.athena_workgroup_name

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/${var.athena_results_prefix}/"
    }
  }
}

resource "aws_dms_replication_instance" "this_dms" {
  replication_instance_id    = var.dms_replication_instance_id
  replication_instance_class = var.dms_instance_class
  allocated_storage          = var.dms_allocated_storage_gb
  publicly_accessible        = false
  multi_az                   = true
}

resource "aws_dms_endpoint" "source_aurora" {
  endpoint_id   = "${var.name_prefix}-aurora-src"
  endpoint_type = "source"
  engine_name   = "aurora-postgresql"

  server_name   = var.aurora_endpoint
  port          = var.aurora_port
  username      = var.aurora_username
  password      = var.aurora_password
  database_name = var.aurora_db_name

  ssl_mode = "require"
}

resource "aws_dms_endpoint" "target_s3" {
  endpoint_id   = "${var.name_prefix}-s3-tgt"
  endpoint_type = "target"
  engine_name   = "s3"

  s3_settings {
    bucket_name             = var.datalake_bucket
    bucket_folder           = var.datalake_prefix
    compression_type        = "GZIP"
    data_format             = "parquet"
    service_access_role_arn = var.dms_s3_access_role_arn

    # Optimización pedida: particionar por fecha para Athena (year/month/day).
    # En DMS se logra con date partitioning en el endpoint.
    date_partition_enabled   = true
    date_partition_sequence  = "YYYYMMDD"
    date_partition_delimiter = "SLASH"
  }
}

locals {
  # Solo schema public y tablas trx_*
  table_mappings = jsonencode({
    rules = [
      {
        "rule-type" = "selection",
        "rule-id"   = "1",
        "rule-name" = "public_trx_only",
        "object-locator" = {
          "schema-name" = "public",
          "table-name"  = "trx_%"
        },
        "rule-action" = "include"
      }
    ]
  })
}

resource "aws_dms_replication_task" "this_dms" {
  replication_task_id      = var.dms_task_id
  migration_type           = "full-load-and-cdc"
  replication_instance_arn = aws_dms_replication_instance.this_dms.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source_aurora.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.target_s3.endpoint_arn

  table_mappings = local.table_mappings
}