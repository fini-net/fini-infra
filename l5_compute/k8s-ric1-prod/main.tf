# main.tf

# DigitalOcean Kubernetes (DOKS) cluster
resource "digitalocean_kubernetes_cluster" "k8s_ric1_prod" {
  name   = var.cluster_name
  region = var.region

  # Use latest stable version; auto_upgrade handles future patch releases
  version = "latest"

  # HA control plane with surge upgrades
  ha            = true
  surge_upgrade = true
  auto_upgrade  = true

  # Enable container registry integration for authenticated pulls
  registry_integration = true

  # Maintenance window: Sunday 04:00-06:00 UTC
  maintenance_policy {
    day        = "sunday"
    start_time = "04:00"
  }

  node_pool {
    name       = "default"
    size       = var.node_pool_size
    auto_scale = true
    min_nodes  = var.node_pool_min_nodes
    max_nodes  = var.node_pool_max_nodes
    node_count = var.node_pool_default_nodes
    tags       = ["env:prod", "k8s:${var.cluster_name}"]
  }

  tags = ["env:prod", "k8s:${var.cluster_name}"]
}

# Container registry integration is enabled on the cluster via registry_integration = true
# This allows DOKS to pull images from the fini-domains-prod registry without
# additional docker credentials resources