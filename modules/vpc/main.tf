provider "aws" {
  region = var.region
}

resource "aws_vpc" "example" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name = "my-vpc"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.example.id
}

resource "aws_subnet" "public" {
  map_public_ip_on_launch = var.map_public_ip_on_launch
  vpc_id                  = aws_vpc.example.id
  availability_zone       = var.availability_zone[count.index]
  count                   = 2
  cidr_block              = cidrsubnet(var.cidr_block, 8, count.index + 1)
}
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.example.id
  availability_zone = var.availability_zone[count.index]
  count             = 2
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index + 3)
}
resource "aws_subnet" "database" {
  vpc_id            = aws_vpc.example.id
  availability_zone = var.availability_zone[count.index]
  count             = 2
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index + 5)
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_rt"
  }
}
resource "aws_route_table_association" "public_rta" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "eip" {
  domain = "vpc"
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "NAT"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "private_rt"
  }
}
resource "aws_route_table_association" "private_rta" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table" "database_rt" {
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "database_rt"
  }
}
resource "aws_route_table_association" "database_rta" {
  count          = 2
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database_rt.id
}

resource "aws_security_group" "endpoint_sg" {
  vpc_id      = aws_vpc.example.id
  description = "all traffic from app security groups"
  name        = "endpoint_sg"
  tags = {
    Name = "endpoint_sg"
  }
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.example.id
  service_name = "com.amazonaws.${var.region}.s3"

  tags = {
    Name = "s3-endpoint"
  }
}
resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.example.id
  service_name      = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.endpoint_sg.id,
  ]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = var.private_dns_enabled
}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.example.id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.endpoint_sg.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = var.private_dns_enabled
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.example.id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.endpoint_sg.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = var.private_dns_enabled
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.example.id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.endpoint_sg.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = var.private_dns_enabled
}

resource "aws_vpc_endpoint" "secret_manager" {
  vpc_id            = aws_vpc.example.id
  service_name      = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.endpoint_sg.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = var.private_dns_enabled
}
resource "aws_vpc_endpoint" "rds" {
  vpc_id            = aws_vpc.example.id
  service_name      = "com.amazonaws.${var.region}.rds"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.endpoint_sg.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = var.private_dns_enabled
}
resource "aws_vpc_endpoint" "logs" {
  vpc_id            = aws_vpc.example.id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.endpoint_sg.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = var.private_dns_enabled
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id            = aws_vpc.example.id
  service_name      = "com.amazonaws.${var.region}.sqs"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.endpoint_sg.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = var.private_dns_enabled
}

resource "aws_vpc_endpoint" "sns" {
  vpc_id            = aws_vpc.example.id
  service_name      = "com.amazonaws.${var.region}.sns"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.endpoint_sg.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = var.private_dns_enabled
}