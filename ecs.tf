# 1. CloudWatch Log Group pro sber logu z Nginx kontejneru
resource "aws_cloudwatch_log_group" "nginx" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7 # Logy starsi nez 7 dni se automaticky smazou
  
  tags = {
    Name = "${var.project_name}-logs"
  }
}

# 2. Vytvoreni samotneho ECS Clusteru
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

# 3. Definice ukolu (Task Definition) pro Nginx kontejner
resource "aws_ecs_task_definition" "nginx" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc" # Fargate vyzaduje sitovy rezim awsvpc
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" # Presne podle zadani
  memory                   = "512" # Presne podle zadani
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  
  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:alpine" # Presne podle zadani
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

# 4. ECS Sluzba (Service), ktera udrzuje kontejner v chodu a poji ho s Load Balancerem
resource "aws_ecs_service" "nginx" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    # Pouzijeme existujici podsite nactene v network.tf
    subnets          = data.aws_subnets.public.ids 
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true # Fargate ve vychozi VPC potrebuje verejnou IP pro stazeni image z internetu
  }
  
  # Propojeni s Load Balancerem
  load_balancer {
    target_group_arn = aws_lb_target_group.nginx.arn
    container_name   = "nginx" # Musi se shodovat s jmenem kontejneru v Task Definition vyse
    container_port   = 80
  }
  
  # Sluzba pocka, dokud se nevytvori listener na Load Balanceru
  depends_on = [aws_lb_listener.nginx]
  
  tags = {
    Name = "${var.project_name}-service"
  }
}