# Subscribe the account to Amazon GuardDuty. Fintech defaults: the detector is
# enabled, findings are published every FIFTEEN_MINUTES (the fastest cadence),
# and every protection feature that does not require an additional_configuration
# block is turned on. The whole module is a no-op when enabled = false.
resource "aws_guardduty_detector" "this" {
  count = local.enabled ? 1 : 0

  enable                       = var.enable
  finding_publishing_frequency = var.finding_publishing_frequency

  tags = local.tags
}

# One detector-feature toggle per entry in var.features. Each value is ENABLED
# or DISABLED. The default set covers the features that need no
# additional_configuration block; runtime-monitoring features can be added by
# the caller (they require their own additional_configuration and are therefore
# left out of the default map — see README).
resource "aws_guardduty_detector_feature" "this" {
  for_each = local.enabled ? var.features : {}

  detector_id = aws_guardduty_detector.this[0].id
  name        = each.key
  status      = each.value
}

# Optional: export findings to an S3 bucket. GuardDuty requires a customer-
# managed KMS key to encrypt exported findings, so both the bucket ARN and the
# key ARN must be supplied together. Rendered only when publishing_s3_arn is set.
resource "aws_guardduty_publishing_destination" "this" {
  count = local.enabled && var.publishing_s3_arn != null ? 1 : 0

  detector_id     = aws_guardduty_detector.this[0].id
  destination_arn = var.publishing_s3_arn
  kms_key_arn     = var.publishing_kms_arn
}
