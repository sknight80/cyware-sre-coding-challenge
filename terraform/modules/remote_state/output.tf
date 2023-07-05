output "bucket_name" {
  value = aws_s3_bucket.bucket.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.lock_table.id
}
