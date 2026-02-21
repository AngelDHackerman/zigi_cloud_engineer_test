resource "aws_s3_bucket" "athena_results" {
  bucket = var.athena_results_bucket
}