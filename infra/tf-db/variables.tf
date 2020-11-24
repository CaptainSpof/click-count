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

variable "node_types" {
  type = map
  default = {
    staging    = "cache.t2.micro"
    production = "cache.t2.micro"
  }
}

variable "parameter_group_names" {
  type = map
  default = {
    staging    = "default.redis6.x"
    production = "default.redis6.x"
  }
}

variable "num_node_groups" {
  type = map
  default = {
    staging    = 1
    production = 1
  }
}

variable "replicas_per_node_groups" {
  type = map
  default = {
    staging    = 0
    production = 0
  }
}
