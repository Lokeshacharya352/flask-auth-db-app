variable "aws_region" {
  description = "AWS region to create the state bucket and lock table in"
  type        = string
  default     = "us-east-2"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform remote state. S3 bucket names are global across ALL AWS accounts, so pick something specific (e.g. include your name/org + project)."
  type        = string
  default     = "flask-db-auth-app-tfstate-bucket"
  # No default on purpose — you must choose a unique name.
  # Example: "lokesh-flask-db-app-tfstate"
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for state locking"
  type        = string
  default     = "flask-db-auth-app-tf-locks"
}
