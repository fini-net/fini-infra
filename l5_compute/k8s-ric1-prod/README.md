# l5_compute/k8s-ric1-prod

Terraform configuration for the DigitalOcean Kubernetes (DOKS) cluster `k8s-ric1-prod`.

## Overview

This module provisions a DOKS cluster in the `ric1` region with a highly available
control plane, auto-upgrading Kubernetes version, and an autoscaling default node pool.
It also integrates with the existing `fini-domains-prod` container registry for
authenticated image pulls.

## Usage

### Initialize

```bash
just tf-init l5_compute/k8s-ric1-prod
```

### Plan

```bash
just tf-plan l5_compute/k8s-ric1-prod
```

### Apply

```bash
just tf-apply l5_compute/k8s-ric1-prod
```

### View State

```bash
just tf-state l5_compute/k8s-ric1-prod
```

### View Outputs

```bash
just tf-output l5_compute/k8s-ric1-prod
```

## Configuration

### Variables

- `onepassword_path` - Path to the 1Password CLI (default: "op")
- `region` - DigitalOcean region (default: "ric1")
- `environment` - Environment name (default: "prod")
- `cluster_name` - DOKS cluster name (default: "k8s-ric1-prod")
- `node_pool_size` - Droplet size for default node pool (default: "s-2vcpu-4gb")
- `node_pool_min_nodes` - Minimum nodes for autoscaling (default: 2)
- `node_pool_max_nodes` - Maximum nodes for autoscaling (default: 5)
- `node_pool_default_nodes` - Default node count (default: 2)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.10 |
| digitalocean | ~> 2.0 |
| onepassword | ~> 2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| digitalocean | ~> 2.0 |
| onepassword | ~> 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [digitalocean_kubernetes_cluster.k8s_ric1_prod](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_cluster) | resource |
| [onepassword_item.digocean_fini](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/data-sources/item) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| cluster\_name | Name of the DOKS cluster | `string` | `"k8s-ric1-prod"` | no |
| environment | Environment name (dev, staging, prod) | `string` | `"prod"` | no |
| node\_pool\_max\_nodes | Maximum number of nodes in the default node pool | `number` | `5` | no |
| node\_pool\_min\_nodes | Minimum (and initial) number of nodes in the default node pool | `number` | `2` | no |
| node\_pool\_size | Droplet size for the default node pool | `string` | `"s-2vcpu-4gb"` | no |
| onepassword\_path | Path to the 1password op command. | `string` | `"op"` | no |
| region | DigitalOcean region for the DOKS cluster | `string` | `"ric1"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| cluster\_endpoint | The Kubernetes API server endpoint |
| cluster\_id | The ID of the DOKS cluster |
| cluster\_name | The name of the DOKS cluster |
| cluster\_region | The region where the DOKS cluster is deployed |
| cluster\_urn | The URN of the DOKS cluster |
| environment | Environment name |
| node\_pool\_name | The name of the default node pool |
| node\_pool\_node\_count | The current number of nodes in the default node pool |
| node\_pool\_size | The droplet size of the default node pool |
| region | DigitalOcean region |
| registry\_integration | Whether container registry integration is enabled for the cluster |
<!-- END_TF_DOCS -->
