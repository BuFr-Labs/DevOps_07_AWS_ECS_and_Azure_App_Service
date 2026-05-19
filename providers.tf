terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Zde zadej REALNY nazev tveho rucne vytvoreneho S3 bucketu
    bucket = "tfstate-bufr-devops-ukol7" 
    key    = "ecs-demo/terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = var.aws_region
}