# l5_compute/mon-nagios

Terraform configuration for the Nagios monitoring server (`mon00.fini.net`).

## Overview

This module manages the DigitalOcean droplet that hosts the Nagios monitoring
infrastructure. The droplet was originally created manually and has been
imported into Terraform for infrastructure-as-code management.

## Usage

### Initialize

```bash
just tf-init l5_compute/mon-nagios
```

### Plan

```bash
just tf-plan l5_compute/mon-nagios
```

### Apply

```bash
just tf-apply l5_compute/mon-nagios
```

### View State

```bash
just tf-state l5_compute/mon-nagios
```

### View Outputs

```bash
just tf-output l5_compute/mon-nagios
```

## Import History

This droplet was imported from existing DigitalOcean infrastructure:

```bash
# Find the droplet ID
doctl compute droplet list --format ID,Name,PublicIPv4,Region | grep mon00

# Import into Terraform state
just tf-import l5_compute/mon-nagios digitalocean_droplet.mon_nagios <droplet-id>
```

## Configuration

### Variables

- `onepassword_path` - Path to the 1Password CLI (default: "op")
- `droplet_name` - Name of the droplet (default: "mon00")
- `hostname` - FQDN for the server (default: "mon00.fini.net")

### Output Variables

- `droplet_id` - Droplet ID
- `droplet_urn` - Droplet URN
- `ipv4_address` - Public IPv4 address
- `ipv4_address_private` - Private IPv4 address
- `ipv6_address` - Public IPv6 address
- `name` - Droplet name
- `region` - Deployment region
- `size` - Droplet size/plan
- `image` - OS image
- `hostname` - FQDN

## Monitoring

This droplet runs Nagios for infrastructure monitoring and alerting.

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
| digitalocean | 2.71.0 |
| onepassword | 2.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_droplet.mon_nagios](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet) | resource |
| [onepassword_item.digocean_fini](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/data-sources/item) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| droplet\_name | Name of the monitoring droplet | `string` | `"mon00"` | no |
| hostname | Fully qualified domain name for the monitoring server | `string` | `"mon00.fini.net"` | no |
| onepassword\_path | Path to the 1password op command. | `string` | `"op"` | no |

## Outputs

| Name | Description |
|------|-------------|
| droplet\_id | The ID of the monitoring droplet |
| droplet\_urn | The URN of the monitoring droplet |
| hostname | The fully qualified domain name for the monitoring server |
| image | The image/OS of the monitoring droplet |
| ipv4\_address | The public IPv4 address of the monitoring droplet |
| ipv4\_address\_private | The private IPv4 address of the monitoring droplet |
| ipv6\_address | The public IPv6 address of the monitoring droplet |
| name | The name of the monitoring droplet |
| region | The region where the monitoring droplet is deployed |
| size | The size/plan of the monitoring droplet |
<!-- END_TF_DOCS -->
