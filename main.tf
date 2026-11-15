module "network" {
  source = "./modules/network"

  vpc_cidr              = var.vpc_cidr
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
}

module "iam" {
  source = "./modules/iam"

  task_execution_role_name  = var.task_execution_role_name
  ecs_service_role_name     = var.ecs_service_role_name
  task_execution_policy_arn = var.task_execution_policy_arn
  ecs_service_policy_arn    = var.ecs_service_policy_arn
}

module "security_groups" {
  source = "./modules/security-groups"

  vpc_id                     = module.network.vpc_id
  vpc_cidr                   = var.vpc_cidr
  s3_endpoint_prefix_list_id = module.network.s3_endpoint_prefix_list_id
  alb_security_group_name    = var.alb_security_group_name
  ecs_security_group_name    = var.ecs_security_group_name
  alb_ingress_cidr_blocks    = var.alb_ingress_cidr_blocks
  alb_listener_port          = var.alb_listener_port
  frontend_port              = var.frontend_service.container_port
  backend_port               = var.backend_service.container_port
}

module "load_balancer" {
  source = "./modules/load-balancer"

  name                       = var.alb_name
  internal                   = var.alb_internal
  vpc_id                     = module.network.vpc_id
  public_subnet_ids          = module.network.public_subnet_ids
  security_group_id          = module.security_groups.alb_security_group_id
  listener_port              = var.alb_listener_port
  frontend_port              = var.frontend_service.container_port
  backend_port               = var.backend_service.container_port
  frontend_target_group_name = var.frontend_target_group_name
  backend_target_group_name  = var.backend_target_group_name
  frontend_health_check_path = var.frontend_service.health_check_path
  backend_health_check_path  = var.backend_service.health_check_path
  backend_path_pattern       = var.backend_path_pattern
  backend_rule_priority      = var.backend_rule_priority
}

module "ecs" {
  source = "./modules/ecs"

  cluster_name                = var.ecs_cluster_name
  repository_name             = var.ecr_repository_name
  image_scan_on_push          = var.image_scan_on_push
  task_execution_role_arn     = module.iam.task_execution_role_arn
  vpc_id                      = module.network.vpc_id
  private_subnet_ids          = module.network.private_subnet_ids
  security_group_id           = module.security_groups.ecs_security_group_id
  frontend_service            = var.frontend_service
  backend_service             = var.backend_service
  frontend_autoscaling        = var.frontend_autoscaling
  backend_autoscaling         = var.backend_autoscaling
  frontend_target_group_arn   = module.load_balancer.frontend_target_group_arn
  backend_target_group_arn    = module.load_balancer.backend_target_group_arn
  service_discovery_namespace = var.service_discovery_namespace
  log_group_prefix            = var.log_group_prefix
  log_retention_days          = var.log_retention_days

  depends_on = [
    module.iam,
    module.load_balancer
  ]
}
