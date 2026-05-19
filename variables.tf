variable "aws_region" {
  type        = string
  description = "AWS region, kde bude infrastruktura nasazena"
  default     = "eu-central-1"
}

variable "project_name" {
  type        = string
  description = "Prefix pro názvy všech vytvářených prostředků"
  default     = "ecs-nginx-demo"
}