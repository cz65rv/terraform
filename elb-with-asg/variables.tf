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

variable "asg-name" {
  description = "Default ASG name"
  type        = string
  default     = "rackspace"
}

variable "min-threshold" {
  description = "Default minimum threshold value"
  type        = string
  default     = "30"
}

variable "max-threshold" {
  description = "Default maximum threshold value"
  type        = string
  default     = "70"
}

variable "alarm-period" {
  description = "Default period of time for alarm"
  type        = string
  default     = "120"
}

variable "min-size" {
  description = "Default minimum size of ASG"
  type        = number
  default     = 2
}

variable "desire-size" {
  description = "Default desire size of ASG"
  type        = number
  default     = 3
}

variable "max-size" {
  description = "Default maximum size of ASG"
  type        = number
  default     = 5
}

variable "machine-type" {
  description = "Default instance type"
  type        = string
  default     = "t2.micro"
}

variable "ssh-key" {
  description = "Default SSH for instances"
  type        = string
  default     = "demo-key"
}