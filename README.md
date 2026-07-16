# terraform-aws-guardduty

[![CI](https://github.com/devotica-labs/terraform-aws-guardduty/actions/workflows/ci.yml/badge.svg)](https://github.com/devotica-labs/terraform-aws-guardduty/actions/workflows/ci.yml)
[![Release](https://github.com/devotica-labs/terraform-aws-guardduty/actions/workflows/release.yml/badge.svg)](https://github.com/devotica-labs/terraform-aws-guardduty/actions/workflows/release.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

> Part of the **Devotica** Terraform catalog. Follows the cloudposse module standard (README.yaml-driven docs, the `enabled`/`namespace`/`environment`/`stage`/`name`/`attributes`/`tags`/`label_order` label surface, `examples/complete`, Makefile targets) implemented **natively** — no external naming or build-harness dependencies.

## Introduction

Terraform module that enables **Amazon GuardDuty** — AWS's managed threat-detection service — for an account. It creates a detector, turns on every protection feature that needs no extra wiring, and can optionally export findings to an encrypted S3 bucket.

Defaults are opinionated for a fintech baseline: the **detector is enabled**, findings publish on the fastest cadence (**`FIFTEEN_MINUTES`**), and the default feature map turns on **S3 data events, EKS audit logs, EBS malware protection, RDS login events, and Lambda network logs**. Runtime-monitoring features require their own `additional_configuration` and are left to the caller.

## Usage

```hcl
module "guardduty" {
  source  = "devotica-labs/guardduty/aws"
  version = "~> 0.1"

  namespace = "dvtca"
  stage     = "prod"
  name      = "security"

  # Fintech defaults cover the rest: detector enabled, FIFTEEN_MINUTES cadence,
  # and all no-extra-config protection features ENABLED.
  tags = local.tags
}
```

Exporting findings to a central, KMS-encrypted S3 bucket:

```hcl
module "guardduty" {
  source  = "devotica-labs/guardduty/aws"
  version = "~> 0.1"

  namespace = "dvtca"
  stage     = "prod"
  name      = "security"

  publishing_s3_arn  = module.security_logs_bucket.arn
  publishing_kms_arn = module.kms.key_arn

  # Tune the feature map if needed (values are ENABLED / DISABLED):
  features = {
    S3_DATA_EVENTS         = "ENABLED"
    EKS_AUDIT_LOGS         = "ENABLED"
    EBS_MALWARE_PROTECTION = "ENABLED"
    RDS_LOGIN_EVENTS       = "ENABLED"
    LAMBDA_NETWORK_LOGS    = "ENABLED"
  }
}
```

To add runtime monitoring, add `RUNTIME_MONITORING` (or `EKS_RUNTIME_MONITORING`, but not both) to `features` — note those features also need an `additional_configuration` block, which this module's default set intentionally avoids to keep `validate`/`plan` clean.

See [`examples/basic`](examples/basic) and [`examples/complete`](examples/complete).

## Defaults that matter

| Setting | Default | Why |
|---------|---------|-----|
| `enable` | `true` | The detector is active (threat detection on) the moment it's created. |
| `finding_publishing_frequency` | `FIFTEEN_MINUTES` | Findings surface on the fastest cadence AWS offers. |
| `features` | all `ENABLED` | S3 data events, EKS audit logs, EBS malware protection, RDS login events, Lambda network logs — every protection that needs no extra config. |
| `publishing_s3_arn` | `null` | Finding export is opt-in; when set, `publishing_kms_arn` is required (exports are CMK-encrypted). |

## How this fits the Devotica catalog

GuardDuty is the account-level threat-detection layer beneath the rest of the catalog. Pair it with `terraform-aws-securityhub` for aggregated findings, and point `publishing_s3_arn` at a central security-logging bucket (e.g. one from `terraform-aws-s3-bucket`) with a CMK from `terraform-aws-kms-key`.

## Makefile Targets

```
make fmt       # terraform fmt -recursive
make validate  # terraform init -backend=false && terraform validate
make test      # terraform test (unit + contract; integration needs AWS creds)
make readme    # regenerate the terraform-docs block below
```

<!-- BEGIN_TF_DOCS -->
<!-- terraform-docs regenerates this block via `make readme` / CI. Inputs and
     outputs are documented in variables.tf and outputs.tf. -->
<!-- END_TF_DOCS -->

## License

[Apache 2.0](LICENSE) © Devotica
