resource "aws_s3_bucket" "athena_results" {
  bucket = var.athena_results_bucket
}

resource "aws_athena_workgroup" "this_dms" {
  name = var.athena_workgroup_name

  configuration {
    enforce_workgroup_configuration = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/${var.athena_results_prefix}/"
    }
  }
}

resource "aws_dms_replication_instance" "this_dms" {
  replication_instance_id = var.dms_replication_instance_id
  replication_instance_class = var.dms_instance_class
  allocated_storage = var.dms_allocated_storage_gb
  publicly_accessible = false
  multi_az = true
}

resource "aws_dms_endpoint" "source_aurora" {
  endpoint_id = "${var.name_prefix}-aurora-src"
  endpoint_type = "source"
  engine_name = "aurora-postgresql"

  server_name = var.aurora_endpoint
  port = var.aurora_port
  username = var.aurora_username
  password = var.aurora_password
  database_name = var.aurora_db_name

  ssl_mode = "require"
}