terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = "ap-south-1"
}

data "aws_availability_zones" "available" {}