variable "aws_region" {
  description = "Default aws region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_name" {
  description = "Default VPC name"
  type        = string
  default     = "infra-vpc"
}

variable "vpc_cidr" {
  description = "Default CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

