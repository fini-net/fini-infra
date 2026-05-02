# outputs.tf

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "region" {
  description = "DigitalOcean region"
  value       = var.region
}

output "cluster_id" {
  description = "The ID of the DOKS cluster"
  value       = digitalocean_kubernetes_cluster.k8s_ric1_prod.id
}

output "cluster_name" {
  description = "The name of the DOKS cluster"
  value       = digitalocean_kubernetes_cluster.k8s_ric1_prod.name
}

output "cluster_region" {
  description = "The region where the DOKS cluster is deployed"
  value       = digitalocean_kubernetes_cluster.k8s_ric1_prod.region
}

output "cluster_endpoint" {
  description = "The Kubernetes API server endpoint"
  value       = digitalocean_kubernetes_cluster.k8s_ric1_prod.endpoint
}

output "cluster_urn" {
  description = "The URN of the DOKS cluster"
  value       = digitalocean_kubernetes_cluster.k8s_ric1_prod.urn
}

output "node_pool_name" {
  description = "The name of the default node pool"
  value       = digitalocean_kubernetes_cluster.k8s_ric1_prod.node_pool[0].name
}

output "node_pool_size" {
  description = "The droplet size of the default node pool"
  value       = digitalocean_kubernetes_cluster.k8s_ric1_prod.node_pool[0].size
}

output "node_pool_node_count" {
  description = "The current number of nodes in the default node pool"
  value       = digitalocean_kubernetes_cluster.k8s_ric1_prod.node_pool[0].node_count
}

output "registry_integration" {
  description = "Whether container registry integration is enabled for the cluster"
  value       = digitalocean_kubernetes_cluster.k8s_ric1_prod.registry_integration
}