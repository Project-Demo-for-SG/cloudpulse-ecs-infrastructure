variable "cluster_name" {
  description = "Name of the ECS cluster."
  type        = string
}

variable "repository_name" {
  description = "Name of the shared ECR repository."
  type        = string
}

variable "image_scan_on_push" {
  description = "Whether ECR scans images when they are pushed."
  type        = bool
}

variable "task_execution_role_arn" {
  description = "ARN of the ECS task execution IAM role."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC hosting the service discovery namespace."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the ECS services."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID assigned to the ECS services."
  type        = string
}

variable "frontend_service" {
  description = "Frontend ECS task and service settings."
  type = object({
    family            = string
    service_name      = string
    container_name    = string
    container_port    = number
    desired_count     = number
    cpu               = number
    memory            = number
    image_tag         = string
    health_check_path = string
    log_stream_prefix = string
  })
}

variable "backend_service" {
  description = "Backend ECS task and service settings."
  type = object({
    family            = string
    service_name      = string
    container_name    = string
    container_port    = number
    desired_count     = number
    cpu               = number
    memory            = number
    image_tag         = string
    health_check_path = string
    log_stream_prefix = string
  })
}

variable "frontend_autoscaling" {
  description = "Frontend ECS service autoscaling limits, targets, and cooldowns."
  type = object({
    min_capacity       = number
    max_capacity       = number
    cpu_target         = number
    memory_target      = number
    scale_out_cooldown = number
    scale_in_cooldown  = number
  })
}

variable "backend_autoscaling" {
  description = "Backend ECS service autoscaling limits, targets, and cooldowns."
  type = object({
    min_capacity       = number
    max_capacity       = number
    cpu_target         = number
    memory_target      = number
    scale_out_cooldown = number
    scale_in_cooldown  = number
  })
}

variable "frontend_target_group_arn" {
  description = "ARN of the frontend load balancer target group."
  type        = string
}

variable "backend_target_group_arn" {
  description = "ARN of the backend load balancer target group."
  type        = string
}

variable "service_discovery_namespace" {
  description = "Private DNS namespace used for ECS service discovery."
  type        = string
}

variable "log_group_prefix" {
  description = "Prefix used for ECS CloudWatch log group names."
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days."
  type        = number
}
