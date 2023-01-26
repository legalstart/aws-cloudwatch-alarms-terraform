variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

variable "slack_webhook_url" {
  type = string
}

variable "slack_channel" {
  type = string
}

variable "slack_username" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "lambda_s3_bucket" {
  type = string
}