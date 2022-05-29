####################### VPC for ELB and ASG ########################
resource "aws_vpc" "infra-vpc" {
  cidr_block           = "172.32.0.0/16"
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = var.vpc_name
  }
}

#################### NAT & Internet Gateway creation ###################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.infra-vpc.id

  tags = {
    Name = "elb-igw"
  }
}

resource "aws_eip" "eip-ngw" {
  vpc = true
}
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip-ngw.id
  subnet_id     = aws_subnet.pub-subnet[0].id
  tags = {
    "Name" = "pvt-ngw"
  }

  depends_on = [aws_internet_gateway.igw]

}

################## Private subnet for Autoscaling Group ######################

resource "aws_subnet" "pvt-subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.infra-vpc.id
  cidr_block              = "172.32.2${count.index+1}.0/24"
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = false

tags = {
    Name = "pvt-subnet-${count.index+1}"
    }
}

################### Routing configuration for private subnets ###############
resource "aws_route_table" "pvt-rt" {
  vpc_id = aws_vpc.infra-vpc.id
    
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "pvt-rt"
  }
}

resource "aws_route_table_association" "pvt-rta" {
  count = 3
  subnet_id      = aws_subnet.pvt-subnet.*.id[count.index]
  route_table_id = aws_route_table.pvt-rt.id
}


############ Public subnet for Load Balancer ##########################

resource "aws_subnet" "pub-subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.infra-vpc.id
  cidr_block              = "172.32.3${count.index+1}.0/24"
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = true

tags = {
    Name = "pub-subnet-${count.index+1}"
    }
}

################### Routing configuration for public subnets

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.infra-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "pub-rt"
  }
}

resource "aws_route_table_association" "pub-rta" {
  count = 3
  subnet_id      = aws_subnet.pub-subnet.*.id[count.index]
  route_table_id = aws_route_table.pub-rt.id
}

#################### Security group for ASG instances, this will only allow HTTP traffic from load balancer security and SSH within VPC

resource "aws_security_group" "pvt-sg" {
  name        = "pvt-sg"
  vpc_id      = aws_vpc.infra-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.32.0.0/24"]
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
    Name = "pvt-sg"
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

  depends_on = [aws_internet_gateway.igw]
}