# l1_privilege/do-spaces-keys

Access keys for digital ocean spaces "buckets" (like S3).

## Permissions

- Global access would be `fullaccess` and this is not limited to a single
  bucket so you should not specify a bucket to confuse things.
- Bucket-level access can be either `read` or `readwrite`.  You should
  specify a bucket for these.

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

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_spaces_key.key-fini-web-content](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/spaces_key) | resource |
| [onepassword_item.digocean_fini](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/data-sources/item) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (dev, staging, prod) | `string` | `"prod"` | no |
| onepassword\_path | Path to the 1password op command. | `string` | `"op"` | no |
| region | DigitalOcean region | `string` | `"nyc3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| content\_key\_access | Access key for the fini-web-content bucket |
| content\_key\_secret | Secret key for the fini-web-content bucket |
| environment | Environment name |
| region | DigitalOcean region |
<!-- END_TF_DOCS -->
