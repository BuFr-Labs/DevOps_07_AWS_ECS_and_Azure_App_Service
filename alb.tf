# 1. Vytvoreni samotneho Application Load Balanceru
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false # false znamena, ze bude verejne dostupny z internetu
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.public.ids # Pouzijeme podsite z naseho network.tf
  
  tags = {
    Name = "${var.project_name}-alb"
  }
}

# 2. Cilova skupina (Target Group) - kam bude ALB smerovat provoz
resource "aws_lb_target_group" "nginx" {
  name        = "${var.project_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.myvpc.id
  target_type = "ip" # Pro AWS Fargate v rezimu awsvpc MUSI byt target_type nastaven na "ip"
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/" # Kontrola hlavni stranky Nginx
    matcher             = "200" # Ocekavame HTTP status kod 200 OK
  }
  
  tags = {
    Name = "${var.project_name}-tg"
  }
}

# 3. Posluchac (Listener) na portu 80
resource "aws_lb_listener" "nginx" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }
}