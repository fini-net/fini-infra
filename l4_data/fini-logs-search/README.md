# fini-logs-search

DigitalOcean Managed OpenSearch cluster for ingesting and searching application logs
from the App Platform applications.

## Overview

This module provisions a small OpenSearch cluster designed to receive and index logs
from DigitalOcean App Platform applications, particularly from the `app-fini-domain-trust`
ingress layer application.

## Architecture

- **Layer**: L4 Data (databases and data stores)
- **Engine**: OpenSearch 2.x (managed by DigitalOcean)
- **Initial Size**: 1 node, 1vCPU, 2GB RAM
- **Region**: NYC3

## Usage

### Initialize and Apply

```bash
# From anywhere in the project
just tf-init l4_data/fini-logs-search
just tf-plan l4_data/fini-logs-search
just tf-apply l4_data/fini-logs-search
```

### View Cluster Information

```bash
just tf-output l4_data/fini-logs-search
```

### Configure App Platform Log Forwarding

DigitalOcean App Platform natively supports forwarding logs to managed OpenSearch clusters.

**Step 1**: Get the configuration values

```bash
# Get all App Platform log forwarding configuration values
just tf-output l4_data/fini-logs-search app_platform_endpoint
just tf-output l4_data/fini-logs-search app_platform_index
just tf-output l4_data/fini-logs-search ingest_user
just tf-output l4_data/fini-logs-search ingest_user_password
```

**Step 2**: Add to your App Platform app spec

See `app-platform-log-config.example.yaml` for configuration examples. You can either:

- **Option 1 (Recommended)**: Use `cluster_name` for DigitalOcean Managed OpenSearch
- **Option 2**: Use `endpoint` with basic auth for any OpenSearch cluster

**Via Control Panel**:

1. Go to Apps > Your App > Settings > Log Forwarding
2. Click Edit and select "Managed OpenSearch"
3. Enter the endpoint, username, password, and index name from the outputs above

**Via App Spec** (add to your app configuration):

```yaml
log_destinations:
  - name: fini-logs-search
    open_search:
      cluster_name: fini-logs-search
      index_name: app-logs
```

## Configuration

### Index Lifecycle Management (ISM)

The module automatically configures ISM policies for log retention and management:

- **Active State** (0-7 days): Full read/write access with rollover after 7 days or 10GB
- **Warm State** (7-30 days): Read-only, reduces replicas to 0 to save storage
- **Delete State** (30+ days): Automatically deletes old indices

You can adjust the retention period by modifying `log_retention_days` in `terraform.tfvars`.

### Index Template

An index template is automatically created for `app-logs-*` indices with:

- Optimized settings for log data (single shard, no replicas for small cluster)
- Field mappings for common log fields (timestamp, level, message, etc.)
- Automatic application of the ISM policy
- Write alias `app-logs` for log ingestion

### Network Access and App Platform Log Forwarding

**IMPORTANT**: DigitalOcean App Platform log forwarding does NOT work with trusted
sources/firewall enabled. The configuration defaults to `enable_firewall = false`
to support App Platform native log forwarding.

If you need to restrict access for manual queries:

1. Set `enable_firewall = true` in `terraform.tfvars`
2. Add IP addresses to `allowed_ips`
3. **WARNING**: This will break App Platform log forwarding

## Scaling

To scale the cluster:

- Increase `node_count` for horizontal scaling
- Change `node_size` to a larger plan for vertical scaling

Available sizes include:

- `db-s-1vcpu-2gb` (current)
- `db-s-2vcpu-4gb`
- `db-s-4vcpu-8gb`
- And larger sizes as needed

## Monitoring

Monitor cluster health through:

- DigitalOcean Control Panel
- OpenSearch Dashboards (included with managed cluster)
- Terraform outputs for status checks

## Cost Considerations

The current configuration (1 node, 1vCPU, 2GB) is the smallest available OpenSearch
cluster size. Review DigitalOcean pricing before scaling.

## Related Resources

- [DigitalOcean Managed OpenSearch Documentation](https://docs.digitalocean.com/products/databases/opensearch/)
- [OpenSearch Documentation](https://opensearch.org/docs/latest/)

## TODO

- [ ] Configure log forwarding from App Platform
- [x] Set up index lifecycle management policies
- [x] Configure retention policies for log data
- [ ] Add cluster health monitoring/alerts
- [ ] Configure OpenSearch Dashboards access

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.10 |
| digitalocean | ~> 2.0 |
| onepassword | ~> 2.0 |
| opensearch | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| digitalocean | 2.69.0 |
| onepassword | 2.2.1 |
| opensearch | 2.3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_database_cluster.logs_search](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_cluster) | resource |
| [digitalocean_database_firewall.logs_search_firewall](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_firewall) | resource |
| [digitalocean_database_user.logs_ingest](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_user) | resource |
| [opensearch_index.app_logs_initial](https://registry.terraform.io/providers/opensearch-project/opensearch/latest/docs/resources/index) | resource |
| [opensearch_index_template.app_logs_template](https://registry.terraform.io/providers/opensearch-project/opensearch/latest/docs/resources/index_template) | resource |
| [opensearch_ism_policy.app_logs_policy](https://registry.terraform.io/providers/opensearch-project/opensearch/latest/docs/resources/ism_policy) | resource |
| [onepassword_item.digocean_fini](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/data-sources/item) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_ips | List of IP addresses allowed to connect to the OpenSearch cluster (only used if enable\_firewall=true) | `list(string)` | `[]` | no |
| cluster\_name | Name of the OpenSearch cluster | `string` | `"fini-logs-search"` | no |
| enable\_firewall | Enable firewall/trusted sources (WARNING: disables App Platform log forwarding) | `bool` | `false` | no |
| environment | Environment name (dev, staging, prod) | `string` | `"prod"` | no |
| log\_retention\_days | Number of days to retain logs before deletion | `number` | `30` | no |
| node\_count | Number of nodes in the OpenSearch cluster | `number` | `1` | no |
| node\_size | Size slug for OpenSearch cluster nodes | `string` | `"db-s-1vcpu-2gb"` | no |
| onepassword\_path | Path to the 1password op command. | `string` | `"op"` | no |
| opensearch\_version | Version of OpenSearch to deploy | `string` | `"2"` | no |
| region | DigitalOcean region for the OpenSearch cluster | `string` | `"nyc3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| app\_platform\_endpoint | Endpoint URL for App Platform log forwarding (format: https://hostname:port) |
| app\_platform\_index | Index name to use in App Platform log forwarding configuration |
| cluster\_host | The hostname of the OpenSearch cluster |
| cluster\_id | The ID of the OpenSearch cluster |
| cluster\_port | The port of the OpenSearch cluster |
| cluster\_private\_uri | The private URI of the OpenSearch cluster |
| cluster\_uri | The URI of the OpenSearch cluster |
| cluster\_urn | The URN of the OpenSearch cluster |
| database\_name | The default database name |
| ingest\_user | Username for log ingestion |
| ingest\_user\_password | Password for log ingestion user |
| ism\_policy\_id | ID of the ISM policy for application logs |
| log\_index\_alias | Alias for writing logs (use this in your log forwarders) |
| log\_retention\_days | Number of days logs are retained before deletion |
<!-- END_TF_DOCS -->
