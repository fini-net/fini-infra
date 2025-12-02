# terraform.tfvars

# OpenSearch cluster configuration
cluster_name       = "fini-logs-search"
opensearch_version = "2"
node_size          = "db-s-1vcpu-2gb"
node_count         = 1
region             = "nyc3"
environment        = "prod"

# Network access control
# TODO: Add specific IP addresses that should have access to the cluster
allowed_ips = []
