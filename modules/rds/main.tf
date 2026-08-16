provider "aws" {
  region = var.region
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  vpc_id      = var.vpc_id
  description = "Allow traffic from app security group"
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }
  egress = []

}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "subnet_group"
  subnet_ids = var.database_subnet_ids[*]

  tags = {
    Name = "DB-subnet-group"
  }
}

resource "aws_db_instance" "instance" {
  allocated_storage           = var.allocated_storage[terraform.workspace]
  storage_type                = var.storage_type
  engine                      = "postgres"
  engine_version              = var.engine_version
  instance_class              = var.instance_class[terraform.workspace]
  db_name                     = var.db_name
  skip_final_snapshot         = true
  username                    = "orema"
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids      = [aws_security_group.rds_sg.id]
  publicly_accessible         = false
}

