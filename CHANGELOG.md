# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:`/`BREAKING CHANGE:` → major).

## 0.1.0 (2026-07-16)


### Features

* **ci:** add architecture-diagram workflow + renderer ([0f41ff6](https://github.com/devotica-labs/terraform-aws-guardduty/commit/0f41ff6ce61edd8f4eeecbab058d01dab6c09aaf))
* initial release of terraform-aws-guardduty ([f65fcc4](https://github.com/devotica-labs/terraform-aws-guardduty/commit/f65fcc452ef6dd27d56abbd5538468c15e558c62))


### Bug Fixes

* **ci:** drop dead pip/scripts dependabot entry; tflint clean ([4a01795](https://github.com/devotica-labs/terraform-aws-guardduty/commit/4a0179597db5b942bcccfe99e500a5f2d7530187))

## [Unreleased]

### Added

- Initial release: enable Amazon GuardDuty threat detection for an account. Creates
  a detector with fintech-safe defaults — enabled, `FIFTEEN_MINUTES` finding
  cadence — and a feature map that turns on every protection needing no extra
  configuration (S3 data events, EKS audit logs, EBS malware protection, RDS login
  events, Lambda network logs). Optional finding export to a KMS-encrypted S3
  bucket via `publishing_s3_arn` / `publishing_kms_arn`. Native `label.tf` naming;
  derived from `cloudposse/terraform-aws-guardduty`.
