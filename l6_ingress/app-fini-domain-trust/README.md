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
| digitalocean | ~> 2.0 |
| onepassword | ~> 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_app.trust_static_site](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/app) | resource |
| [onepassword_item.digocean_fini](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/data-sources/item) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain\_name | Custom domain for the app | `string` | `"vccinc.net"` | no |
| environment | Environment name (dev, staging, prod) | `string` | `"prod"` | no |
| github\_branch | GitHub branch to deploy from | `string` | `"main"` | no |
| github\_repo | GitHub repository in owner/repo format | `string` | `"fini-net/fini-domain-trust"` | no |
| onepassword\_path | Path to the 1password op command. | `string` | `"op"` | no |
| region | DigitalOcean region for the App Platform app | `string` | `"nyc"` | no |
| source\_dir | Directory containing the static site source | `string` | `"trust/public"` | no |

## Outputs

| Name | Description |
|------|-------------|
| active\_deployment\_id | The ID of the currently active deployment |
| app\_id | The ID of the app |
| app\_urn | The URN of the app |
| custom\_domain | The custom domain configured for the app |
| default\_ingress | The default URL to access the app |
| github\_branch | The GitHub branch being deployed |
| github\_repo | The GitHub repository used as source |
| live\_url | The live URL of the app |
<!-- END_TF_DOCS -->