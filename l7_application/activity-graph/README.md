# l7_application/activity-graph

Self-hosted fork of [github-readme-activity-graph](https://github.com/Ashutosh00710/github-readme-activity-graph)
deployed on DigitalOcean App Platform. The upstream Vercel deployment is
billing-locked (HTTP 402), so we run our own fork
([fini-net/github-readme-activity-graph](https://github.com/fini-net/github-readme-activity-graph))
as a containerized Express 5 service.

The app reads `process.env.TOKEN` as a Bearer token for the GitHub GraphQL
contributions API. During `tofu apply` the `onepassword` provider reads the
token from 1Password (item `github-activity-graph-token` in vault `Private`)
and configures it as a DO App Platform `SECRET`/`RUN_TIME` env var — it is
never stored in code or version control.

See [chicks-net/www-chicks-net#371](https://github.com/chicks-net/www-chicks-net/issues/371)
for the full self-hosting rationale.

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
| digitalocean | 2.100.0 |
| onepassword | 2.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [digitalocean_app.activity_graph](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/app) | resource |
| [onepassword_item.digocean_fini](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/data-sources/item) | data source |
| [onepassword_item.github_pat](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/data-sources/item) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| app\_name | Name of the DO App Platform app | `string` | `"activity-graph"` | no |
| dockerfile\_path | Path to the Dockerfile relative to the repo root | `string` | `"Dockerfile"` | no |
| environment | Environment name (dev, staging, prod) | `string` | `"prod"` | no |
| github\_branch | GitHub branch to deploy from | `string` | `"deploy"` | no |
| github\_repo | GitHub repository in owner/repo format | `string` | n/a | yes |
| http\_port | Port the service listens on (DO injects this as PORT env) | `number` | `5100` | no |
| instance\_size\_slug | DO App Platform instance size ($5/mo, 512 MiB, 1 shared vCPU) | `string` | `"apps-s-1vcpu-0.5gb"` | no |
| onepassword\_path | Path to the 1password op command. | `string` | `"op"` | no |
| region | DigitalOcean region for the App Platform app | `string` | `"nyc"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| active\_deployment\_id | The ID of the currently active deployment |
| app\_id | The ID of the app |
| app\_urn | The URN of the app |
| default\_ingress | The default URL to access the app |
| github\_branch | The GitHub branch being deployed |
| github\_repo | The GitHub repository used as source |
| live\_url | The live URL of the app |
<!-- END_TF_DOCS -->
