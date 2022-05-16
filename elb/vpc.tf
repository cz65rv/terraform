# VPC for ELB
resource "aws_vpc" "infra-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "infra-vpc"
  }
}

# Subnet for ELB
resource "aws_subnet" "infra-subnet" {
  count = 3
  
  vpc_id                  = aws_vpc.infra-vpc.id
  cidr_block              = "10.0.${count.index+1}.0/24"
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = true

tags = {
    Name = "infra-subnet-${count.index+1}"
    }
}

# Internet gateway for ELB Subnet
resource "aws_internet_gateway" "infra-igw" {
  vpc_id = aws_vpc.infra-vpc.id

  tags = {
    Name = "infra-igw"
  }
}

# Routing table for ELB VPC
resource "aws_route_table" "infra-rt" {
  vpc_id = aws_vpc.infra-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.infra-igw.id
  }

  tags = {
    Name = "infra-rt"
  }
}

# Routing table association
resource "aws_route_table_association" "infra-rta" {
  count = 3

  subnet_id      = aws_subnet.infra-subnet.*.id[count.index]
  route_table_id = aws_route_table.infra-rt.id
}

# Security group to access the instances & elb
resource "aws_security_group" "infra-sg" {
  name        = "infra-sg"
  vpc_id      = aws_vpc.infra-vpc.id

# SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Ensure the VPC has an Internet gateway or this step will fail
  depends_on = [aws_internet_gateway.infra-igw]
}
