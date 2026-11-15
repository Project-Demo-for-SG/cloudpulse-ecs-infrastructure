output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role."
  value       = aws_iam_role.task_execution.arn
}

output "ecs_service_role_arn" {
  description = "ARN of the ECS service role."
  value       = aws_iam_role.ecs_service.arn
}
