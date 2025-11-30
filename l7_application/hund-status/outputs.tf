# outputs.tf
# Hund.io Status Page Outputs

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "hund_api_endpoint" {
  description = "Hund.io API endpoint"
  value       = var.hund_api_endpoint
}

# Example outputs for when resources are created
# output "statuspage_id" {
#   description = "Hund.io status page ID"
#   value       = hund_statuspage.fini.id
# }

# output "statuspage_url" {
#   description = "Public URL of the status page"
#   value       = hund_statuspage.fini.url
# }
