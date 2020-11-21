variable "project_name" {
  type        = map
  description = "Name of the project."
  default = {
    staging    = "click-count-app-staging"
    production = "click-count-app-production"
  }
}

variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

variable "env" {
  description = "env: staging or production"
}
