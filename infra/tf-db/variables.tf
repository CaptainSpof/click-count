variable "environment_name" {
  type        = map
  description = "Name of the project."
  default = {
    staging    = "staging"
    production = "production"
  }
}

variable "project_name" {
  type        = string
  description = "Name of the project."
  default     = "click-count"
}

variable "stack" {
  type    = string
  default = "redis"
}


variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

variable "env" {
  description = "env: staging or production"
}
