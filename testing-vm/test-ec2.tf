terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket         = "teraaform-state-cz65rv"
    key            = "global/s3/teraaform-state-cz65rv"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks-cz65rv"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-south-1"
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

######### EC2 instance block for server
resource "aws_instance" "test-server" {
  ami               = data.aws_ami.latest-ubuntu1.id
  instance_type     = "t2.micro"
  key_name          = "default"

  tags = {
    Name = "test-server"
  }
}

####### Data volume creation
resource "aws_ebs_volume" "datavol" {
 availability_zone = "ap-south-1a"
 size = 5
  
 tags = {
        Name = "data-volume"
  }

}
resource "aws_volume_attachment" "datavol-attach" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.datavol.id
  instance_id = aws_instance.test-server.id
}