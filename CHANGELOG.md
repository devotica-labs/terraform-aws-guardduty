# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:`/`BREAKING CHANGE:` → major).

## [Unreleased]

### Added

- Initial release: enable Amazon GuardDuty threat detection for an account. Creates
  a detector with fintech-safe defaults — enabled, `FIFTEEN_MINUTES` finding
  cadence — and a feature map that turns on every protection needing no extra
  configuration (S3 data events, EKS audit logs, EBS malware protection, RDS login
  events, Lambda network logs). Optional finding export to a KMS-encrypted S3
  bucket via `publishing_s3_arn` / `publishing_kms_arn`. Native `label.tf` naming;
  derived from `cloudposse/terraform-aws-guardduty`.
