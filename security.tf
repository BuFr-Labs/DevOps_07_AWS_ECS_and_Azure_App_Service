# Security Group pro Application Load Balancer (ALB)
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ALB - umožňuje přístup z internetu"
  vpc_id      = data.aws_vpc.myvpc.id
  
  # Povolujeme příchozí HTTP provoz na portu 80 z jakékoliv IP adresy na světě
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Povolujeme veškerý odchozí provoz (např. pro stahování aktualizací z internetu)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Security Group pro samotné ECS úkoly (Nginx kontejnery)
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Security group for ECS tasks - povluje provoz POUZE z ALB"
  vpc_id      = data.aws_vpc.myvpc.id
  
  # KLÍČOVÉ MÍSTO: Příchozí provoz na port 80 je povolen POUZE pokud přichází přes ALB SG
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  # Povolujeme odchozí provoz (Fargate kontejner si tudy bude stahovat Nginx obraz z Docker Hubu)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.project_name}-ecs-tasks-sg"
  }
}