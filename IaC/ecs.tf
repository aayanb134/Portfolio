resource "aws_ecs_cluster" "main" {
  name = "portfolio-cluster"
}

resource "aws_ecs_task_definition" "service" {
  family                   = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = <<TASK_DEFINITION
[
  {
    "name": "portfolio-container",
    "image": "257747315190.dkr.ecr.eu-west-2.amazonaws.com/portfolio:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 5000,
        "hostPort": 5000
      }
    ]
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  depends_on = [aws_iam_role.ecs_execution_role]
}

resource "aws_ecs_service" "main" {
  name            = "portfolio-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.service.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = aws_subnet.public[*].id
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs-tasks.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "portfolio-container"
    container_port   = 5000
  }

  health_check_grace_period_seconds = 300

  depends_on = [aws_lb_listener.http, aws_lb_listener.https, aws_ecs_task_definition.service]
}
