output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "ecr_repository_uri" {
  description = "URI of the shared ECR repository."
  value       = aws_ecr_repository.app.repository_url
}
