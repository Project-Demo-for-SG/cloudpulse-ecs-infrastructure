variable "vpc_id" {
  description = "ID of the VPC hosting the security groups."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR allowed for private workload and load balancer traffic."
  type        = string
}

variable "s3_endpoint_prefix_list_id" {
  description = "Prefix list ID for the S3 gateway endpoint used to pull ECR image layers."
  type        = string
}

variable "alb_security_group_name" {
  description = "Name of the ALB security group."
  type        = string
}

variable "ecs_security_group_name" {
  description = "Name of the ECS tasks security group."
  type        = string
}

variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach the ALB listener."
  type        = list(string)
}

variable "alb_listener_port" {
  description = "Port exposed by the ALB listener."
  type        = number
}

variable "frontend_port" {
  description = "Frontend container port."
  type        = number
}

variable "backend_port" {
  description = "Backend container port."
  type        = number
}
