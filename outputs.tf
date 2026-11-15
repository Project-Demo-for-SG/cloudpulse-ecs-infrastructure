output "alb_dns_name" {
  description = "DNS name of the public application load balancer."
  value       = module.load_balancer.dns_name
}

output "ecr_repository_uri" {
  description = "URI of the ECR repository for frontend and backend images."
  value       = module.ecs.ecr_repository_uri
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.ecs.ecs_cluster_name
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.network.vpc_id
}