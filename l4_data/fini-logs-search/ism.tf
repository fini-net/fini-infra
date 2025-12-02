# ism.tf - Index State Management policies for log retention and lifecycle

# ISM Policy for application logs with retention and rollover
resource "opensearch_ism_policy" "app_logs_policy" {
  policy_id = "app-logs-retention-policy"
  body = jsonencode({
    policy = {
      description   = "Manage application log indices with rollover and retention"
      default_state = "active"

      states = [
        {
          name = "active"
          actions = [
            {
              rollover = {
                min_index_age          = "7d"
                min_primary_shard_size = "10gb"
              }
            }
          ]
          transitions = [
            {
              state_name = "warm"
              conditions = {
                min_index_age = "7d"
              }
            }
          ]
        },
        {
          name = "warm"
          actions = [
            {
              replica_count = {
                number_of_replicas = 0
              }
            }
          ]
          transitions = [
            {
              state_name = "delete"
              conditions = {
                min_index_age = "${var.log_retention_days}d"
              }
            }
          ]
        },
        {
          name = "delete"
          actions = [
            {
              delete = {}
            }
          ]
          transitions = []
        }
      ]
    }
  })

  depends_on = [digitalocean_database_cluster.logs_search]
}

# Index template for application logs
resource "opensearch_index_template" "app_logs_template" {
  name = "app-logs-template"
  body = jsonencode({
    index_patterns = ["app-logs-*"]
    template = {
      settings = {
        number_of_shards         = 1
        number_of_replicas       = 0
        "index.refresh_interval" = "30s"

        # Enable ISM policy (using plugins namespace for OpenSearch 2.x)
        "plugins.index_state_management.policy_id"      = opensearch_ism_policy.app_logs_policy.policy_id
        "plugins.index_state_management.rollover_alias" = "app-logs"
      }
      mappings = {
        properties = {
          "@timestamp" = {
            type = "date"
          }
          message = {
            type = "text"
            fields = {
              keyword = {
                type         = "keyword"
                ignore_above = 256
              }
            }
          }
          level = {
            type = "keyword"
          }
          app_name = {
            type = "keyword"
          }
          environment = {
            type = "keyword"
          }
          host = {
            type = "keyword"
          }
          request_id = {
            type = "keyword"
          }
          duration_ms = {
            type = "long"
          }
          status_code = {
            type = "integer"
          }
          path = {
            type = "keyword"
          }
          method = {
            type = "keyword"
          }
        }
      }
    }
  })

  depends_on = [opensearch_ism_policy.app_logs_policy]
}

# Create initial index with write alias
resource "opensearch_index" "app_logs_initial" {
  name = "app-logs-000001"

  # The index will use the template settings
  # We need to explicitly set the alias for write operations
  aliases = jsonencode({
    "app-logs" = {
      is_write_index = true
    }
  })

  force_destroy = true

  depends_on = [opensearch_index_template.app_logs_template]
}
