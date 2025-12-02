# outputs.tf

output "cluster_id" {
  description = "The ID of the OpenSearch cluster"
  value       = digitalocean_database_cluster.logs_search.id
}

output "cluster_urn" {
  description = "The URN of the OpenSearch cluster"
  value       = digitalocean_database_cluster.logs_search.urn
}

output "cluster_host" {
  description = "The hostname of the OpenSearch cluster"
  value       = digitalocean_database_cluster.logs_search.host
}

output "cluster_port" {
  description = "The port of the OpenSearch cluster"
  value       = digitalocean_database_cluster.logs_search.port
}

output "cluster_uri" {
  description = "The URI of the OpenSearch cluster"
  value       = digitalocean_database_cluster.logs_search.uri
  sensitive   = true
}

output "cluster_private_uri" {
  description = "The private URI of the OpenSearch cluster"
  value       = digitalocean_database_cluster.logs_search.private_uri
  sensitive   = true
}

output "database_name" {
  description = "The default database name"
  value       = digitalocean_database_cluster.logs_search.database
}

output "ingest_user" {
  description = "Username for log ingestion"
  value       = digitalocean_database_user.logs_ingest.name
}

output "ingest_user_password" {
  description = "Password for log ingestion user"
  value       = digitalocean_database_user.logs_ingest.password
  sensitive   = true
}

output "ism_policy_id" {
  description = "ID of the ISM policy for application logs"
  value       = opensearch_ism_policy.app_logs_policy.policy_id
}

output "log_index_alias" {
  description = "Alias for writing logs (use this in your log forwarders)"
  value       = "app-logs"
}

output "log_retention_days" {
  description = "Number of days logs are retained before deletion"
  value       = var.log_retention_days
}

output "app_platform_endpoint" {
  description = "Endpoint URL for App Platform log forwarding"
  value       = "https://${digitalocean_database_cluster.logs_search.host}:${digitalocean_database_cluster.logs_search.port}"
  sensitive   = true
}

output "app_platform_index" {
  description = "Index name to use in App Platform log forwarding configuration"
  value       = "app-logs"
}
