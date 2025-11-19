# l6_ingress/cdn-fini-domain-trust opentofu

Intention: create a CDN with associated bucket and certificate for
serving a set of sites.

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
| digitalocean | 2.68.0 |
| onepassword | 2.1.2 |
| terraform | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_cdn.trust_cdn](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/cdn) | resource |
| [digitalocean_spaces_bucket.trust_origin_bucket](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/spaces_bucket) | resource |
| [digitalocean_spaces_bucket_logging.trust_logging](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/spaces_bucket_logging) | resource |
| [digitalocean_spaces_bucket_policy.trust_public_read](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/spaces_bucket_policy) | resource |
| [onepassword_item.digocean_fini](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/data-sources/item) | data source |
| [terraform_remote_state.logs_cdn](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (dev, staging, prod) | `string` | `"prod"` | no |
| onepassword\_path | Path to the 1password op command. | `string` | `"op"` | no |
| region | DigitalOcean region | `string` | `"nyc3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cdn\_endpoint | CDN endpoint |
| environment | Environment name |
| origin\_bucket\_name | Name of the origin bucket |
| origin\_bucket\_urn | URN of the origin bucket |
| region | DigitalOcean region |
<!-- END_TF_DOCS -->
