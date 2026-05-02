resource "digitalocean_kubernetes_cluster" "k8s_ric1_prod" {
  name   = var.cluster_name
  region = var.region

  version = "latest"

  ha            = true
  surge_upgrade = true
  auto_upgrade  = true

  registry_integration = true

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
    tags       = ["env:${var.environment}", "k8s:${var.cluster_name}"]
  }

  tags = ["env:${var.environment}", "k8s:${var.cluster_name}"]

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [node_pool[0].node_count]
  }
}

# registry_integration = true on the cluster is sufficient for authenticated
# pulls from the fini-domains-prod registry — no separate docker credentials
# resource is needed
