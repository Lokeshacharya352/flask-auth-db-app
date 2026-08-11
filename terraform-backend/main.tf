# terraform-backend/main.tf
#
# BOOTSTRAP STACK — run this ONCE, manually, before anything else.
# This creates the S3 bucket + DynamoDB table that ALL other Terraform
# stacks (terraform/, eks-cluster/) will use as their remote backend.
#
# This stack itself uses LOCAL state (no backend block) — that's intentional.
# You cannot store a bucket's own creation inside itself. Once applied,
# you should rarely (if ever) touch this stack again.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 bucket to hold all remote state files
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  # Prevents accidental deletion of this bucket via `terraform destroy`.
  # You'd have to remove this manually if you ever truly want it gone.
  lifecycle {
    prevent_destroy = true
  }
}

# Versioning lets you recover a previous state file if something goes wrong
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt state at rest — state files can contain sensitive values
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to the state bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking — prevents two people/pipelines
# from running `terraform apply` on the same stack at the same time
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST" # no fixed cost when idle
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
