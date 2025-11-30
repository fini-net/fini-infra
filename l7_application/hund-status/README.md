# Hund.io Status Page

This module manages the Hund.io status page configuration for status.fini.net.

## Overview

Hund.io provides status page hosting and incident management. This Terraform
configuration manages the status page components, metrics, and integrations.

STATUS: on hold due to https://github.com/hundio/terraform-provider-hund/issues/13
so we keep updating hund by hand for now.

## Prerequisites

- 1Password CLI authentication (`op signin`)
- API credentials stored in 1Password vault "Private", item "fini-terraform-hund"
- DigitalOcean credentials stored in 1Password vault "Private", item "digocean-fini2"

## Configuration

The module uses the Hund.io Terraform provider to manage:

- Service components and groups
- Incident templates

## Usage

### Initialize

```bash
just tf-init l7_application/hund-status
```

### Plan Changes

```bash
just tf-plan l7_application/hund-status
```

### Apply Changes

```bash
just tf-apply l7_application/hund-status
```

## Provider Configuration

The Hund provider is configured with:

- **API Key**: Retrieved from 1Password item "fini-terraform-hund"
- **API Endpoint**: `status.fini.net` (configurable via variable)

## State Backend

Remote state is stored in DigitalOcean Spaces:

- **Bucket**: `fini-terraform-state`
- **Key**: `l7_application/hund-status`
- **Region**: `nyc3`

## Next Steps

1. Uncomment the example resources in `main.tf`
2. Customize the status page configuration for your services
3. Add components for each service you want to monitor
4. Configure metrics and alerting thresholds
5. Set up incident templates for common scenarios

## Resources

- [Hund.io Documentation](https://hund.io/docs)
- [Hund Terraform Provider](https://registry.terraform.io/providers/hundio/hund/latest/docs)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
