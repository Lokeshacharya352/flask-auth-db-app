# terraform/backend.tf
#
# This stack's state is stored remotely in S3 (created by ../terraform-backend/).
# Note: values here CANNOT reference variables — Terraform requires backend
# config to be static, so fill in the real bucket/table name after you've
# run terraform-backend once.

terraform {
  backend "s3" {
    bucket         = "flask-db-auth-app-tfstate-bucket" # must match terraform-backend output
    key            = "rds/terraform.tfstate"           # unique path within the bucket for THIS stack
    region         = "us-east-2"
    dynamodb_table = "flask-db-auth-app-tf-locks"
    encrypt        = true
  }
}
