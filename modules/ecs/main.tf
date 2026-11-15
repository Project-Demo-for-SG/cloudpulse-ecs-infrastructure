resource "aws_ecr_repository" "app" {
  name = var.repository_name

  image_scanning_configuration {
    scan_on_push = var.image_scan_on_push
  }
}

resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = var.service_discovery_namespace
  description = "Private DNS namespace for ECS service discovery."
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "backend" {
  name = var.backend_service.container_name

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "${var.log_group_prefix}/${var.frontend_service.log_stream_prefix}"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = "${var.log_group_prefix}/${var.backend_service.log_stream_prefix}"
  retention_in_days = var.log_retention_days
}

data "aws_region" "current" {}

resource "aws_ecs_task_definition" "frontend" {
  family                   = var.frontend_service.family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.frontend_service.cpu
  memory                   = var.frontend_service.memory
  execution_role_arn       = var.task_execution_role_arn

  container_definitions = jsonencode([{
    name      = var.frontend_service.container_name
    image     = "${aws_ecr_repository.app.repository_url}:${var.frontend_service.image_tag}"
    essential = true
    portMappings = [{
      containerPort = var.frontend_service.container_port
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.frontend.name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = var.frontend_service.log_stream_prefix
      }
    }
  }])
}

resource "aws_ecs_task_definition" "backend" {
  family                   = var.backend_service.family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_service.cpu
  memory                   = var.backend_service.memory
  execution_role_arn       = var.task_execution_role_arn

  container_definitions = jsonencode([{
    name      = var.backend_service.container_name
    image     = "${aws_ecr_repository.app.repository_url}:${var.backend_service.image_tag}"
    essential = true
    portMappings = [{
      containerPort = var.backend_service.container_port
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.backend.name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = var.backend_service.log_stream_prefix
      }
    }
  }])
}

resource "aws_ecs_service" "backend" {
  name            = var.backend_service.service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = max(var.backend_service.desired_count, var.backend_autoscaling.min_capacity)
  launch_type     = "FARGATE"

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.backend_target_group_arn
    container_name   = var.backend_service.container_name
    container_port   = var.backend_service.container_port
  }

  service_registries {
    registry_arn = aws_service_discovery_service.backend.arn
  }

  depends_on = [
    aws_cloudwatch_log_group.backend,
  ]
}

resource "aws_ecs_service" "frontend" {
  name            = var.frontend_service.service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = max(var.frontend_service.desired_count, var.frontend_autoscaling.min_capacity)
  launch_type     = "FARGATE"

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = var.frontend_service.container_name
    container_port   = var.frontend_service.container_port
  }

  depends_on = [
    aws_cloudwatch_log_group.frontend,
    aws_ecs_service.backend,
  ]
}

resource "aws_appautoscaling_target" "frontend" {
  max_capacity       = var.frontend_autoscaling.max_capacity
  min_capacity       = var.frontend_autoscaling.min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.frontend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_target" "backend" {
  max_capacity       = var.backend_autoscaling.max_capacity
  min_capacity       = var.backend_autoscaling.min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "frontend_cpu" {
  name               = "${var.frontend_service.service_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.frontend.resource_id
  scalable_dimension = aws_appautoscaling_target.frontend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.frontend.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.frontend_autoscaling.cpu_target
    scale_out_cooldown = var.frontend_autoscaling.scale_out_cooldown
    scale_in_cooldown  = var.frontend_autoscaling.scale_in_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "frontend_memory" {
  name               = "${var.frontend_service.service_name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.frontend.resource_id
  scalable_dimension = aws_appautoscaling_target.frontend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.frontend.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.frontend_autoscaling.memory_target
    scale_out_cooldown = var.frontend_autoscaling.scale_out_cooldown
    scale_in_cooldown  = var.frontend_autoscaling.scale_in_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "backend_cpu" {
  name               = "${var.backend_service.service_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend.resource_id
  scalable_dimension = aws_appautoscaling_target.backend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.backend_autoscaling.cpu_target
    scale_out_cooldown = var.backend_autoscaling.scale_out_cooldown
    scale_in_cooldown  = var.backend_autoscaling.scale_in_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "backend_memory" {
  name               = "${var.backend_service.service_name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend.resource_id
  scalable_dimension = aws_appautoscaling_target.backend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.backend_autoscaling.memory_target
    scale_out_cooldown = var.backend_autoscaling.scale_out_cooldown
    scale_in_cooldown  = var.backend_autoscaling.scale_in_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}
