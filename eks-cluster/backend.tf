terraform {
  backend "s3" {
    bucket         = "flask-db-auth-app-tfstate-bucket" # must match terraform-backend output
    key            = "eks/terraform.tfstate"           # unique path within the bucket for THIS stack
    region         = "us-east-2"
    dynamodb_table = "flask-db-auth-app-tf-locks"
    encrypt        = true
  }
}
