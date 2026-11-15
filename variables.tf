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

variable "budget_alert_email" {
  description = "Email address that receives CloudPulse AWS Budget notifications."
  type        = string
  sensitive   = true
}

variable "enable_cloudpulse_budget" {
  description = "Create the project-tagged budget after the Project cost allocation tag is active."
  type        = bool
  default     = false
}

variable "monthly_budget_limit_usd" {
  description = "Monthly CloudPulse cost budget in USD."
  type        = number
  default     = 35

  validation {
    condition     = var.monthly_budget_limit_usd > 0
    error_message = "The monthly budget limit must be greater than zero."
  }
}

variable "budget_alert_threshold_percent" {
  description = "Actual monthly spend percentage at which the budget sends an alert."
  type        = number
  default     = 80

  validation {
    condition     = var.budget_alert_threshold_percent > 0 && var.budget_alert_threshold_percent <= 100
    error_message = "The budget alert threshold must be greater than zero and no more than 100 percent."
  }
}

variable "budget_forecast_threshold_percent" {
  description = "Forecasted monthly spend percentage at which the budget sends an alert."
  type        = number
  default     = 100

  validation {
    condition     = var.budget_forecast_threshold_percent > 0 && var.budget_forecast_threshold_percent <= 100
    error_message = "The forecast threshold must be greater than zero and no more than 100 percent."
  }
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  type        = string
  default     = "cloudpulse-ecs-cluster"
}

variable "ecr_repository_name" {
  description = "Name of the shared ECR repository for frontend and backend images."
  type        = string
  default     = "cloudpulse-app-repo"
}

variable "image_scan_on_push" {
  description = "Whether ECR scans images when they are pushed."
  type        = bool
  default     = true
}

variable "task_execution_role_name" {
  description = "Name of the ECS task execution IAM role."
  type        = string
  default     = "ecs-task-execution-role"
}

variable "ecs_service_role_name" {
  description = "Name of the ECS service IAM role."
  type        = string
  default     = "ecs-service-role"
}

variable "task_execution_policy_arn" {
  description = "ARN of the managed policy attached to the task execution role."
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "ecs_service_policy_arn" {
  description = "ARN of the managed policy attached to the ECS service role."
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

variable "alb_name" {
  description = "Name of the application load balancer."
  type        = string
  default     = "ecs-app-alb"
}

variable "alb_internal" {
  description = "Whether the application load balancer is internal."
  type        = bool
  default     = false
}

variable "alb_security_group_name" {
  description = "Name of the ALB security group."
  type        = string
  default     = "ecs-alb-sg"
}

variable "ecs_security_group_name" {
  description = "Name of the ECS tasks security group."
  type        = string
  default     = "ecs-tasks-sg"
}

variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach the ALB listener."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_listener_port" {
  description = "Port used by the ALB listener."
  type        = number
  default     = 80
}

variable "frontend_target_group_name" {
  description = "Name of the frontend target group."
  type        = string
  default     = "ecs-frontend-tg"
}

variable "backend_target_group_name" {
  description = "Name of the backend target group."
  type        = string
  default     = "ecs-backend-tg"
}

variable "backend_path_pattern" {
  description = "ALB path pattern routed to the backend target group."
  type        = string
  default     = "/api*"
}

variable "backend_rule_priority" {
  description = "Priority of the ALB listener rule for backend traffic."
  type        = number
  default     = 1
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
  default = {
    family            = "frontend-task"
    service_name      = "frontend-service"
    container_name    = "frontend"
    container_port    = 80
    desired_count     = 1
    cpu               = 256
    memory            = 512
    image_tag         = "frontend-latest"
    health_check_path = "/"
    log_stream_prefix = "frontend"
  }
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
  default = {
    family            = "backend-task"
    service_name      = "backend-service"
    container_name    = "backend"
    container_port    = 3000
    desired_count     = 1
    cpu               = 256
    memory            = 512
    image_tag         = "backend-latest"
    health_check_path = "/api/health"
    log_stream_prefix = "backend"
  }
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
  default = {
    min_capacity       = 1
    max_capacity       = 4
    cpu_target         = 60
    memory_target      = 70
    scale_out_cooldown = 60
    scale_in_cooldown  = 300
  }

  validation {
    condition = (
      var.frontend_autoscaling.min_capacity >= 1 &&
      var.frontend_autoscaling.max_capacity >= var.frontend_autoscaling.min_capacity &&
      var.frontend_autoscaling.cpu_target > 0 && var.frontend_autoscaling.cpu_target <= 100 &&
      var.frontend_autoscaling.memory_target > 0 && var.frontend_autoscaling.memory_target <= 100 &&
      var.frontend_autoscaling.scale_out_cooldown >= 0 &&
      var.frontend_autoscaling.scale_in_cooldown >= 0
    )
    error_message = "Frontend autoscaling requires min_capacity >= 1, max_capacity >= min_capacity, targets between 0 and 100, and non-negative cooldowns."
  }
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
  default = {
    min_capacity       = 1
    max_capacity       = 4
    cpu_target         = 60
    memory_target      = 70
    scale_out_cooldown = 60
    scale_in_cooldown  = 300
  }

  validation {
    condition = (
      var.backend_autoscaling.min_capacity >= 1 &&
      var.backend_autoscaling.max_capacity >= var.backend_autoscaling.min_capacity &&
      var.backend_autoscaling.cpu_target > 0 && var.backend_autoscaling.cpu_target <= 100 &&
      var.backend_autoscaling.memory_target > 0 && var.backend_autoscaling.memory_target <= 100 &&
      var.backend_autoscaling.scale_out_cooldown >= 0 &&
      var.backend_autoscaling.scale_in_cooldown >= 0
    )
    error_message = "Backend autoscaling requires min_capacity >= 1, max_capacity >= min_capacity, targets between 0 and 100, and non-negative cooldowns."
  }
}

variable "service_discovery_namespace" {
  description = "Private DNS namespace used for ECS service discovery."
  type        = string
  default     = "ecscloudpulse.local"
}

variable "log_group_prefix" {
  description = "Prefix used for ECS CloudWatch log group names."
  type        = string
  default     = "/ecs"
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days."
  type        = number
  default     = 7
}
