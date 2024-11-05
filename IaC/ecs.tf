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

  container_definitions = jsonencode([{
    name  = "portfolio-container"
    image = "257747315190.dkr.ecr.eu-west-2.amazonaws.com/portfolio:latest"
    portMappings = [{
      containerPort = 5000
      hostPort      = 5000
    }]
  }])

  depends_on = [aws_iam_role.ecs_execution_role]
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
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
