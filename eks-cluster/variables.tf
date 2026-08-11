variable "cluster_name" {
  default = "flask-eks-cluster"
}

variable "region" {
  default = "us-east-2"
}

variable "vpc_id" {
  description = "Your default VPC ID"
  default     = "vpc-0e9bdffba22113b1d" # your default VPC
}
variable "subnet_ids" {
  default = [
    "subnet-0df1a5ba6c2971110",  # us-east-1a ✅
    "subnet-00f69d3bdc07861a3",  # us-east-1d ✅
    "subnet-0328b5a7d3ebcd0a0"   # us-east-1c ✅
  ]
}
