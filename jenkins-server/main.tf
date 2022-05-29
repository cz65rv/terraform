######### NIC resource block for EC2 Instance resource
resource "aws_network_interface" "test-nic" {
  subnet_id       = aws_subnet.test-subnet.id
  private_ips     = ["10.1.1.21"]
  security_groups = [aws_security_group.test-sg.id]
}

######### EIP block for NIC resource
resource "aws_eip" "test_eip" {
  vpc                       = true
  network_interface         = aws_network_interface.test-nic.id
  associate_with_private_ip = "10.1.1.21"

  depends_on = [aws_internet_gateway.test-igw]
}

#SSH Key block
resource "aws_key_pair" "default-key" {
  key_name   = "default"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZ8zkOP3q+fm91pXM45h3De8qNKC+8JFUdjFImSRhmMreyniHzZQu/k6eU5BYEKokJUHcFKX9amWROsvQZb/zx02jfF5Jr9Z896s4ANX2YoI02jKw7uvlx8oE/q8GDAv7C7JAAjA1fV4TB8ZDiypoRrImc8YxtjtLZUIBXvfRklN0hOY3ycGLVG2D8gGOvCj/uvd4QBD4qr/+TEDxms1zgLNxQShQzHSNmKPsRnMoXaIjs9v7xWN+JymggmNX3SiYUrCxi3ClbnM/Bm8YKo+P73zY3bfCoFripKSNw2uKCBiaKpYjiLav7jfRVs5RsExge5NCvfmiO1sRhSCW5NLut5x/snzX/M9yJ3MglBGOA+CKD3MzEQYQpNw0i938cEKyp5TBU87sseu3ECYNEATs3PUAGJQHJJaskAZ+V033dlVCbo6MFVrBAhBo0LvJnZ0UDBW3Pou9Vo0TYgKs9XWH6u9xsec87v+6VTnF6Q3nozbQoeFWvokoqm0SQXbBZU38= mukesh@master"
  tags = {
    Name = "default"
  }
}

######### EC2 instance block for server
resource "aws_instance" "test-server" {
  ami               = data.aws_ami.latest-ubuntu1.id
  instance_type     = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name          = "default"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.test-nic.id
  }

  user_data = "${file("server-config.sh")}"

  tags = {
    Name = "test-server"
  }
}

######### AMI Data Source to pull latest Ubuntu AMI #########
data "aws_ami" "latest-ubuntu1" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}