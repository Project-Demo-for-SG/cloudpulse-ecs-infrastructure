aws_region   = "us-east-1"
project_name = "CloudPulse"
environment  = "demo"

vpc_cidr              = "10.0.0.0/16"
public_subnet_1_cidr  = "10.0.1.0/24"
public_subnet_2_cidr  = "10.0.2.0/24"
private_subnet_1_cidr = "10.0.3.0/24"
private_subnet_2_cidr = "10.0.4.0/24"

# Replace with an address monitored by the project owner.
budget_alert_email                = "krishteja354@gmail.com"
enable_cloudpulse_budget          = false
monthly_budget_limit_usd          = 35
budget_alert_threshold_percent    = 80
budget_forecast_threshold_percent = 100

ecs_cluster_name          = "cloudpulse-ecs-cluster"
ecr_repository_name       = "cloudpulse-app-repo"
image_scan_on_push        = true
task_execution_role_name  = "ecs-task-execution-role"
ecs_service_role_name     = "ecs-service-role"
task_execution_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
ecs_service_policy_arn    = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"

alb_name                   = "ecs-app-alb"
alb_internal               = false
alb_security_group_name    = "ecs-alb-sg"
ecs_security_group_name    = "ecs-tasks-sg"
alb_ingress_cidr_blocks    = ["0.0.0.0/0"]
alb_listener_port          = 80
frontend_target_group_name = "ecs-frontend-tg"
backend_target_group_name  = "ecs-backend-tg"
backend_path_pattern       = "/api*"
backend_rule_priority      = 1

frontend_service = {
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

backend_service = {
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

frontend_autoscaling = {
  min_capacity       = 1
  max_capacity       = 4
  cpu_target         = 60
  memory_target      = 70
  scale_out_cooldown = 60
  scale_in_cooldown  = 300
}

backend_autoscaling = {
  min_capacity       = 1
  max_capacity       = 4
  cpu_target         = 60
  memory_target      = 70
  scale_out_cooldown = 60
  scale_in_cooldown  = 300
}

service_discovery_namespace = "ecscloudpulse.local"
log_group_prefix            = "/ecs"
log_retention_days          = 7
