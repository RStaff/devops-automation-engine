output "raw_data_bucket" {
  description = "S3 bucket for raw data"
  value       = aws_s3_bucket.raw_data.bucket
}
output "airflow_role_arn" {
  value = aws_iam_role.airflow_ecs.arn
}
