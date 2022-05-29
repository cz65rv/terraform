terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}

provider "http" {}

data "aws_availability_zones" "az" {}