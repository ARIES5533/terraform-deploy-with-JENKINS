variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "key_name" {
  description = "SSH key name in AWS"
  type        = string
  default     = "aries"
}

variable "ec2_name" {
  description = "EC2 instance name tag"
  type        = string
  default     = "my-terraform-ec2-jenkins"
}
