# l4data/tfstate opentofu

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| digitalocean | ~> 2.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| do\_token | DigitalOcean API token | `string` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| region | DigitalOcean region | `string` | `"nyc1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| environment | Environment name |
| region | DigitalOcean region |
