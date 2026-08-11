variable "aws_region" {
  type    = string
  default = "us-east-2"
}
variable "db_name" {
  type = string
  default = "flaskdb"
}
variable "db_username" {
  type = string
  default = "admin"
}
variable "db_password" {
  description = "RDS master password. Do NOT put a real value in .tfvars. Pass via TF_VAR_db_password environment variable or a secrets manager instead."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}
