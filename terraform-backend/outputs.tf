output "state_bucket_name" {
  description = "S3 bucket name to reference in other stacks' backend blocks"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "lock_table_name" {
  description = "DynamoDB table name to reference in other stacks' backend blocks"
  value       = aws_dynamodb_table.terraform_locks.name
}
