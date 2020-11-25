
locals {
  name = "${var.project_name}-${var.stack}-${var.env}"
  short_name = "${var.project_name}-${var.stack}"
  tags = {
    Env         = var.env,
    Project     = var.project_name,
    Provisioner = "terraform"
  }
}

variable "project_name" {
  type        = string
  description = "Name of the project."
  default     = "click-count"
}

variable "environment_name" {
  type        = map
  description = "Name of the project."
  default = {
    staging    = "staging"
    production = "production"
  }
}

variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

variable "env" {
  description = "env: staging or production"
}
