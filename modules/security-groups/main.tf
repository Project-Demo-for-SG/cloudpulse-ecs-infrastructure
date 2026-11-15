resource "aws_security_group" "alb" {
  name        = var.alb_security_group_name
  description = "Security group for the public application load balancer."
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from approved client CIDR blocks."
    from_port   = var.alb_listener_port
    to_port     = var.alb_listener_port
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
}

resource "aws_security_group" "ecs" {
  name        = var.ecs_security_group_name
  description = "Allow application traffic from the load balancer."
  vpc_id      = var.vpc_id

  ingress {
    description     = "Frontend traffic from the load balancer."
    from_port       = var.frontend_port
    to_port         = var.frontend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Backend traffic from the load balancer."
    from_port       = var.backend_port
    to_port         = var.backend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description     = "HTTPS to ECR image layers through the S3 gateway endpoint."
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [var.s3_endpoint_prefix_list_id]
  }
}
