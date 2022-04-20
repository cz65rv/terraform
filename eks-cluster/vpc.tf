#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "eks-cluster-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "eks-cluster-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_subnet" "eks-cluster-subnet" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.eks-cluster-vpc.id

  tags = tomap({
    "Name"                                      = "eks-cluster-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_internet_gateway" "eks-cluster-igw" {
  vpc_id = aws_vpc.eks-cluster-vpc.id

  tags = {
    Name = "eks-cluster"
  }
}

resource "aws_route_table" "eks-cluster-rt" {
  vpc_id = aws_vpc.eks-cluster-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-cluster-igw.id
  }
}

resource "aws_route_table_association" "eks-cluster-rta" {
  count = 2

  subnet_id      = aws_subnet.eks-cluster-subnet.*.id[count.index]
  route_table_id = aws_route_table.eks-cluster-rt.id
}
