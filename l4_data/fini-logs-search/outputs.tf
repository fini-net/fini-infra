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
