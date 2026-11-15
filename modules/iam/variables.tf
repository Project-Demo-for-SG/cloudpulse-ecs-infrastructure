variable "task_execution_role_name" {
  description = "Name of the ECS task execution IAM role."
  type        = string
}

variable "ecs_service_role_name" {
  description = "Name of the ECS service IAM role."
  type        = string
}

variable "task_execution_policy_arn" {
  description = "ARN of the managed policy attached to the task execution role."
  type        = string
}

variable "ecs_service_policy_arn" {
  description = "ARN of the managed policy attached to the ECS service role."
  type        = string
}
