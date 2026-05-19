# Security Group pro Application Load Balancer (ALB)
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ALB - umoznuje pristup z internetu"
  vpc_id      = data.aws_vpc.myvpc.id
  
  # Povolujeme prichozi HTTP provoz na portu 80 z jakékoliv IP adresy na svete
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Povolujeme veskery odchozi provoz (napr. pro stahovani aktualizaci z internetu)
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

# Security Group pro samotne ECS ukoly (Nginx kontejnery)
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Security group for ECS tasks - povoluje provoz POUZE z ALB"
  vpc_id      = data.aws_vpc.myvpc.id
  
  # KLICOVE MISTO: Prichozi provoz na port 80 je povolen POUZE pokud prichazi pres ALB SG
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  # Povolujeme odchozi provoz (Fargate kontejner si tudy bude stahovat Nginx obraz z Docker Hubu)
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