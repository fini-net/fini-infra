# main.tf

# TODO: Configure log forwarding from App Platform
# TODO: Configure retention policies and index lifecycle management
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
# Note: Only created if allowed_ips is not empty
resource "digitalocean_database_firewall" "logs_search_firewall" {
  count      = length(var.allowed_ips) > 0 ? 1 : 0
  cluster_id = digitalocean_database_cluster.logs_search.id

  # Allow connections from specific IPs
  dynamic "rule" {
    for_each = var.allowed_ips
    content {
      type  = "ip_addr"
      value = rule.value
    }
  }

  # Allow connections from DigitalOcean App Platform
  # App Platform doesn't have a fixed IP range, so we'll need to use a tag or specific IP
  # Note: You may need to add specific IPs after deployment
}

# Database user for log ingestion
resource "digitalocean_database_user" "logs_ingest" {
  cluster_id = digitalocean_database_cluster.logs_search.id
  name       = "logs-ingest"
}
