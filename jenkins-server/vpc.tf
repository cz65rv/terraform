#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#  * Security Group
#

resource "aws_vpc" "test-vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "test-vpc"
    
  }
}

resource "aws_subnet" "test-subnet" {
  availability_zone       = "ap-south-1a"
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.test-vpc.id

  tags = {
    Name = "test-subnet"
    
  }
}

resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "test-igw"
  }
}

resource "aws_route_table" "test-rt" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-igw.id
  }
}

resource "aws_route_table_association" "test-rta" {
  subnet_id = aws_subnet.test-subnet.id
  route_table_id = aws_route_table.test-rt.id
}

resource "aws_security_group" "test-sg" {
  name        = "test-sg"
  vpc_id      = aws_vpc.test-vpc.id

ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test-sg"
  }
}