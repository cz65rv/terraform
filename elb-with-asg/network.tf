################### VPC for elb and autoscaling group hosts
resource "aws_vpc" "infra-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = var.vpc_name
  }
}


################## Private subnet for Autoscaling Group so that hosts in ASG are not accessible from internet.

resource "aws_subnet" "asg-pvt-subnet1" {
  vpc_id                  = aws_vpc.infra-vpc.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false

tags = {
    Name = "asg-pvt-subnet1"
    }
}

resource "aws_subnet" "asg-pvt-subnet2" {
  vpc_id                  = aws_vpc.infra-vpc.id
  cidr_block              = "10.0.12.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false

tags = {
    Name = "asg-pvt-subnet2"
    }
}

resource "aws_subnet" "asg-pvt-subnet3" {
  vpc_id                  = aws_vpc.infra-vpc.id
  cidr_block              = "10.0.13.0/24"
  availability_zone       = "ap-south-1c"
  map_public_ip_on_launch = false

tags = {
    Name = "asg-pvt-subnet3"
    }
}


###################### NAT Gateway to provide internet connectivity to instances in ASG for downloading required packages and patches

resource "aws_eip" "eip-ngw" {
  vpc = true
}

resource "aws_nat_gateway" "asg-ngw" {
  allocation_id = aws_eip.eip-ngw.id
  subnet_id     = aws_subnet.elb-pub-subnet[0].id
  tags = {
    "Name" = "asg-ngw"
  }

  depends_on = [aws_internet_gateway.elb-igw]

}


####################### Routing table for private subnets which will provide internet connectivity wihtout exposing them to internet

resource "aws_route_table" "asg-rt" {
  vpc_id = aws_vpc.infra-vpc.id
    
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.asg-ngw.id
  }

  tags = {
    Name = "asg-rt"
  }
}


################### Routing table association for ASG private subnet

resource "aws_route_table_association" "asg-rta1" {
  subnet_id      = aws_subnet.asg-pvt-subnet1.id
  route_table_id = aws_route_table.asg-rt.id
}

resource "aws_route_table_association" "asg-rta2" {
  subnet_id      = aws_subnet.asg-pvt-subnet2.id
  route_table_id = aws_route_table.asg-rt.id
}

resource "aws_route_table_association" "asg-rta3" {
  subnet_id      = aws_subnet.asg-pvt-subnet3.id
  route_table_id = aws_route_table.asg-rt.id
}


############ Public subnet for Load Balancer so that, it is accessible and be available for users

resource "aws_subnet" "elb-pub-subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.infra-vpc.id
  cidr_block              = "10.0.${count.index+1}.0/24"
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = true

tags = {
    Name = "elb-pub-subnet-${count.index+1}"
    }
}


#################### Internet gateway for elb subnet

resource "aws_internet_gateway" "elb-igw" {
  vpc_id = aws_vpc.infra-vpc.id

  tags = {
    Name = "elb-igw"
  }
}


################### Routing table for elb subnets

resource "aws_route_table" "elb-rt" {
  vpc_id = aws_vpc.infra-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.elb-igw.id
  }

  tags = {
    Name = "elb-rt"
  }
}


##################### Routing table association public subnets

resource "aws_route_table_association" "elb-rta" {
  count = 3
  subnet_id      = aws_subnet.elb-pub-subnet.*.id[count.index]
  route_table_id = aws_route_table.elb-rt.id
}


#################### Security group for ASG instances, this will only allow HTTP traffic from load balancer security and SSH from within VPC

resource "aws_security_group" "asg-sg" {
  name        = "asg-sg"
  vpc_id      = aws_vpc.infra-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
    description = "Allow to connect ASG intances internally via SSH"
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb-sg.id]
    description     = "Allow http traffic to ASG instances from Load Balancer secuirty group only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "asg-sg"
  }

}


#################### Security group for loadbalancer to make it available and accessible from internet

resource "aws_security_group" "elb-sg" {
  name        = "elb-sg"
  vpc_id      = aws_vpc.infra-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elb-sg"
  }

  depends_on = [aws_internet_gateway.elb-igw]
}