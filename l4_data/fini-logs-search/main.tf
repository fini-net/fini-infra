# main.tf

# TODO: Configure log forwarding from App Platform
# TODO: Consider adding alerts for cluster health

# DigitalOcean Managed OpenSearch cluster for application logs
resource "digitalocean_database_cluster" "logs_search" {
  name       = var.cluster_name
  engine     = "opensearch"
  version    = var.opensearch_version
  size       = var.node_size
  region     = var.region
  node_count = var.node_count

  tags = [
    "environment:${var.environment}",
    "purpose:log-analytics",
    "layer:l4-data"
  ]
}

# Firewall rules for OpenSearch cluster
# IMPORTANT: App Platform log forwarding does NOT work with trusted sources/firewall enabled
# If you need to forward logs from App Platform, do NOT create firewall rules
# Only create firewall for non-App Platform access (e.g., manual queries, debugging)
resource "digitalocean_database_firewall" "logs_search_firewall" {
  count      = var.enable_firewall && length(var.allowed_ips) > 0 ? 1 : 0
  cluster_id = digitalocean_database_cluster.logs_search.id

  # Allow connections from specific IPs
  dynamic "rule" {
    for_each = var.allowed_ips
    content {
      type  = "ip_addr"
      value = rule.value
    }
  }
}

# Database user for log ingestion
resource "digitalocean_database_user" "logs_ingest" {
  cluster_id = digitalocean_database_cluster.logs_search.id
  name       = "logs-ingest"
}
