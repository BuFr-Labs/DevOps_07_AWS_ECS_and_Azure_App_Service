variable "aws_region" {
  type        = string
  description = "AWS region, kde bude infrastruktura nasazena"
  default     = "eu-central-1"
}

variable "project_name" {
  type        = string
  description = "Prefix pro nazvy vsech vytvarenych prostredku"
  default     = "ecs-nginx-demo"
}