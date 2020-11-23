# output "configuration_endpoint" {
#   value = aws_elasticache_cluster.click_count.configuration_endpoint
# }
#

# output "redis_address" {
#   value = aws_elasticache_cluster.click_count.address
# }

output "primary_endpoint_address" {
  value = aws_elasticache_replication_group.click_count.primary_endpoint_address
}
