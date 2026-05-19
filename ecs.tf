# 1. CloudWatch Log Group pro sběr logů z Nginx kontejneru
resource "aws_cloudwatch_log_group" "nginx" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7 # Logy starší než 7 dní se automaticky smažou, ať neplatíš zbytečně moc
  
  tags = {
    Name = "${var.project_name}-logs"
  }
}

# 2. Vytvoření samotného ECS Clusteru
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = {
    Name = "${var.project_name}-cluster"
  }
}

# 3. Definice úkolu (Task Definition) pro Nginx kontejner
resource "aws_ecs_task_definition" "nginx" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc" # Fargate vyžaduje síťový režim awsvpc
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" # Přesně podle zadání
  memory                   = "512" # Přesně podle zadání
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  
  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:alpine" # Přesně podle zadání
      essential = true
      
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.nginx.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
  
  tags = {
    Name = "${var.project_name}-task"
  }
}

# 4. ECS Služba (Service), která udržuje kontejner v chodu a pojí ho s Load Balancerem
resource "aws_ecs_service" "nginx" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    # Použijeme existující podsítě načtené v network.tf
    subnets          = data.aws_subnets.public.ids 
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true # Fargate ve výchozí VPC potřebuje veřejnou IP pro stažení image z internetu
  }
  
  # Propojení s Load Balancerem
  load_balancer {
    target_group_arn = aws_lb_target_group.nginx.arn
    container_name   = "nginx" # Musí se shodovat s jménem kontejneru v Task Definition výše
    container_port   = 80
  }
  
  # Služba počká, dokud se nevytvoří listener na Load Balanceru
  depends_on = [aws_lb_listener.nginx]
  
  tags = {
    Name = "${var.project_name}-service"
  }
}