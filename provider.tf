terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.30.0, < 4.31.0"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 1.1"
}

provider "aws" {
  region = var.aws_region
}
