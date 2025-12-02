# terraform.tfvars

# OpenSearch cluster configuration
cluster_name       = "fini-logs-search"
opensearch_version = "2"
node_size          = "db-s-1vcpu-2gb"
node_count         = 1
region             = "nyc3"
environment        = "prod"

# Network access control
# WARNING: App Platform log forwarding does NOT work with firewall/trusted sources enabled
# Keep enable_firewall = false to allow App Platform log forwarding
enable_firewall = false
allowed_ips     = []

# Log retention configuration
log_retention_days = 30
