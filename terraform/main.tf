

data "aws_vpc" "main" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# Reads outputs from the eks-cluster/ stack's state file directly from S3 —
# avoids manually copy-pasting the security group ID (which would go stale
# if the cluster were ever recreated). Requires eks-cluster/ to have been
# applied at least once already.

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "flask-db-auth-app-tfstate-bucket"
    key    = "eks/terraform.tfstate"
    region = "us-east-2"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "flask-db-subnet-group"
  subnet_ids = data.aws_subnets.public.ids

  tags = {
    Name = "flask-db-subnet-group"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "flask-db-sg"
  description = "Allow DB access"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description = "Allow MySQL access from EKS Nodes only"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [data.terraform_remote_state.eks.outputs.cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "mysql" {
  identifier             = "flask-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  tags = {
    Name = "flask-db"
  }
}