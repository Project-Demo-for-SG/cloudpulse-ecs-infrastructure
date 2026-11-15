variable "aws_region" {
  description = "AWS region in which to create the infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project tag value used for resource ownership and cost allocation."
  type        = string
  default     = "CloudPulse"
}

variable "environment" {
  description = "Environment tag value, such as demo, development, or production."
  type        = string
  default     = "demo"
}


variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for the first public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for the second public subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for the first private subnet."
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for the second private subnet."
  type        = string
  default     = "10.0.4.0/24"
}