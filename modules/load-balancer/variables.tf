variable "name" {
  description = "Name of the application load balancer."
  type        = string
}

variable "internal" {
  description = "Whether the load balancer is internal."
  type        = bool
}

variable "vpc_id" {
  description = "ID of the VPC hosting the target groups."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the load balancer."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID attached to the load balancer."
  type        = string
}

variable "listener_port" {
  description = "Port used by the HTTP listener."
  type        = number
}

variable "frontend_port" {
  description = "Frontend target group port."
  type        = number
}

variable "backend_port" {
  description = "Backend target group port."
  type        = number
}

variable "frontend_target_group_name" {
  description = "Name of the frontend target group."
  type        = string
}

variable "backend_target_group_name" {
  description = "Name of the backend target group."
  type        = string
}

variable "frontend_health_check_path" {
  description = "Health check path used for frontend targets."
  type        = string
}

variable "backend_health_check_path" {
  description = "Health check path used for backend targets."
  type        = string
}

variable "backend_path_pattern" {
  description = "Listener path pattern routed to the backend."
  type        = string
}

variable "backend_rule_priority" {
  description = "Priority of the backend listener rule."
  type        = number
}
