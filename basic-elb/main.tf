# ELB resource block
resource "aws_elb" "infra-elb" {
  name            = "infra-elb"
  subnets         = aws_subnet.infra-subnet.*.id
  security_groups = [aws_security_group.infra-sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

# Register instances automatically with ELB
  instances                   = aws_instance.infra-instance.*.id
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}

# Session stickiness policy with ELB
resource "aws_lb_cookie_stickiness_policy" "default" {
  name                     = "lbpolicy"
  load_balancer            = aws_elb.infra-elb.id
  lb_port                  = 80
  cookie_expiration_period = 600
}



# Key pair defination block
resource "aws_key_pair" "default-key" {
  key_name   = "default-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZ8zkOP3q+fm91pXM45h3De8qNKC+8JFUdjFImSRhmMreyniHzZQu/k6eU5BYEKokJUHcFKX9amWROsvQZb/zx02jfF5Jr9Z896s4ANX2YoI02jKw7uvlx8oE/q8GDAv7C7JAAjA1fV4TB8ZDiypoRrImc8YxtjtLZUIBXvfRklN0hOY3ycGLVG2D8gGOvCj/uvd4QBD4qr/+TEDxms1zgLNxQShQzHSNmKPsRnMoXaIjs9v7xWN+JymggmNX3SiYUrCxi3ClbnM/Bm8YKo+P73zY3bfCoFripKSNw2uKCBiaKpYjiLav7jfRVs5RsExge5NCvfmiO1sRhSCW5NLut5x/snzX/M9yJ3MglBGOA+CKD3MzEQYQpNw0i938cEKyp5TBU87sseu3ECYNEATs3PUAGJQHJJaskAZ+V033dlVCbo6MFVrBAhBo0LvJnZ0UDBW3Pou9Vo0TYgKs9XWH6u9xsec87v+6VTnF6Q3nozbQoeFWvokoqm0SQXbBZU38= mukesh@master"

  tags = {
    Name = "default-key"
  }
}

# EC2 Instances which will be used behind elb
resource "aws_instance" "infra-instance" {
  count = 3

  instance_type          = "t3.micro"
  ami                    = data.aws_ami.latest-ubuntu1.id
  key_name               = "default-key"
  vpc_security_group_ids = [aws_security_group.infra-sg.id]
  subnet_id              = aws_subnet.infra-subnet.*.id[count.index]
  user_data              = "${file("userdata.sh")}"

  tags = {
    Name = "infra-server-${count.index+1}"
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