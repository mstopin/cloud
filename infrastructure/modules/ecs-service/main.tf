locals {
  container_definitions = [
    for container_definition in var.container_definitions : {
      name = container_definition.name
      image = container_definition.image
      essential = container_definition.essential

      portMappings = [
        for published_port in container_definition.published_ports : {
          containerPort = published_port
          hostPort = 0
          protocol = "tcp"
        }
      ]
      
      environment = container_definition.environment

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-region" = var.region
          "awslogs-group" = aws_cloudwatch_log_group.main.name
          "awslogs-stream-prefix" = "${var.name_prefix}-${var.name}"
        }
      }
    }
  ]

  published_ports = distinct(flatten([
    for container in var.container_definitions : container.published_ports
  ]))
}

data "aws_iam_policy_document" "task" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  name = "${var.name_prefix}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.task.json
}

resource "aws_iam_role" "task" {
  name = "${var.name_prefix}-${var.name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.task.json
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "main" {
  name = "/ecs/${var.name_prefix}/${var.name}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "main" {
  family = "${var.name_prefix}-${var.name}"

  execution_role_arn = aws_iam_role.task_execution.arn
  task_role_arn = aws_iam_role.task.arn

  network_mode = "bridge"
  cpu = var.cpu
  memory = var.memory

  container_definitions = jsonencode(local.container_definitions)
}

resource "aws_ecs_service" "main" {
  name = "${var.name_prefix}-${var.name}"
  
  cluster = var.cluster_id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count = var.desired_count
  force_new_deployment = true

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight = 1
    base = 100
  }

  ordered_placement_strategy {
    type = "spread"
    field = "attribute:ecs.availability-zone"
  }

  dynamic "load_balancer" {
    for_each = var.container_definitions

    content {
      target_group_arn = var.alb_target_group_arn

      container_name = load_balancer.value.name
      container_port = load_balancer.value.published_ports[0]
    }
  }

  depends_on = [var.alb_target_group_arn]
}
