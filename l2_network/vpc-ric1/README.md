# l2_network/vpc-ric1

VPC for the DOKS cluster in the ric1 region.

This module creates a DigitalOcean VPC that will be referenced by the DOKS
cluster (l5_compute) via `terraform_remote_state`. The `vpc_uuid` on a DOKS
cluster is immutable, so the VPC must be provisioned first.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->