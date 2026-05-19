# 1. Vytvoření samotného Application Load Balanceru
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false # false znamená, že bude veřejně dostupný z internetu
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.public.ids # Použijeme podsítě z našeho network.tf
  
  tags = {
    Name = "${var.project_name}-alb"
  }
}

# 2. Cílová skupina (Target Group) – kam bude ALB směrovat provoz
resource "aws_lb_target_group" "nginx" {
  name        = "${var.project_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.myvpc.id
  target_type = "ip" # Pro AWS Fargate v režimu awsvpc MUSÍ být target_type nastaven na "ip"
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/" # Kontrola hlavní stránky Nginx
    matcher             = "200" # Očekáváme HTTP status kód 200 OK
  }
  
  tags = {
    Name = "${var.project_name}-tg"
  }
}

# 3. Posluchač (Listener) na portu 80
resource "aws_lb_listener" "nginx" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }
}