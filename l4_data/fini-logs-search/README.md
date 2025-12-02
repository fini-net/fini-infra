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
# From the project root
just tf-init l4_data/fini-logs-search
just tf-plan l4_data/fini-logs-search
just tf-apply l4_data/fini-logs-search
```

### View Cluster Information

```bash
just tf-output l4_data/fini-logs-search
```

### Access Credentials

The OpenSearch cluster credentials are managed by Terraform and can be retrieved
from the outputs. The `logs-ingest` user is created for log forwarding operations.

```bash
# Get the cluster URI (sensitive)
just tf-output l4_data/fini-logs-search cluster_uri

# Get the ingest user credentials (sensitive)
just tf-output l4_data/fini-logs-search ingest_user
just tf-output l4_data/fini-logs-search ingest_user_password
```

## Configuration

### Network Access

By default, the cluster has restrictive firewall rules. To allow access:

1. Add IP addresses to `allowed_ips` variable in `terraform.tfvars`
2. Configure App Platform to forward logs (see below)

### Log Forwarding from App Platform

DigitalOcean App Platform does not natively support forwarding logs to OpenSearch.
Common approaches include:

1. **Sidecar Container**: Deploy a log shipper (Fluent Bit, Filebeat) as a sidecar
2. **External Service**: Use an intermediate log aggregator (Logstash, Vector)
3. **API Integration**: Configure application to send logs directly to OpenSearch

See the TODO comments in `main.tf` for implementation tasks.

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
- [ ] Set up index lifecycle management policies
- [ ] Configure retention policies for log data
- [ ] Add cluster health monitoring/alerts
- [ ] Configure OpenSearch Dashboards access
- [ ] Document log schema and indexing patterns

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.10 |
| digitalocean | ~> 2.0 |
| onepassword | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| digitalocean | 2.69.0 |
| onepassword | 2.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_database_cluster.logs_search](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_cluster) | resource |
| [digitalocean_database_firewall.logs_search_firewall](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_firewall) | resource |
| [digitalocean_database_user.logs_ingest](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_user) | resource |
| [onepassword_item.digocean_fini](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/data-sources/item) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_ips | List of IP addresses allowed to connect to the OpenSearch cluster | `list(string)` | `[]` | no |
| cluster\_name | Name of the OpenSearch cluster | `string` | `"fini-logs-search"` | no |
| environment | Environment name (dev, staging, prod) | `string` | `"prod"` | no |
| node\_count | Number of nodes in the OpenSearch cluster | `number` | `1` | no |
| node\_size | Size slug for OpenSearch cluster nodes | `string` | `"db-s-1vcpu-2gb"` | no |
| onepassword\_path | Path to the 1password op command. | `string` | `"op"` | no |
| opensearch\_version | Version of OpenSearch to deploy | `string` | `"2"` | no |
| region | DigitalOcean region for the OpenSearch cluster | `string` | `"nyc3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_host | The hostname of the OpenSearch cluster |
| cluster\_id | The ID of the OpenSearch cluster |
| cluster\_port | The port of the OpenSearch cluster |
| cluster\_private\_uri | The private URI of the OpenSearch cluster |
| cluster\_uri | The URI of the OpenSearch cluster |
| cluster\_urn | The URN of the OpenSearch cluster |
| database\_name | The default database name |
| ingest\_user | Username for log ingestion |
| ingest\_user\_password | Password for log ingestion user |
<!-- END_TF_DOCS -->
