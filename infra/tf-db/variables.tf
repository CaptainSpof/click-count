
variable "stack" {
  type    = string
  default = "redis"
}

# Elasticache

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

variable "number_cache_clusters" {
  type = map
  default = {
    staging    = 1
    production = 1
  }
}
