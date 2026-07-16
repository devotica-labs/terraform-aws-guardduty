# Contract tests — the defaults callers depend on stay stable across versions:
# the detector publishes every FIFTEEN_MINUTES and every default protection
# feature is ENABLED.

mock_provider "aws" {}

variables {
  namespace = "dvtca"
  stage     = "test"
  name      = "contract"
}

run "finding_publishing_frequency_default" {
  command = plan
  assert {
    condition     = one(aws_guardduty_detector.this).finding_publishing_frequency == "FIFTEEN_MINUTES"
    error_message = "Default finding_publishing_frequency must remain FIFTEEN_MINUTES."
  }
}

run "all_default_features_enabled" {
  command = plan
  # The default feature set: exactly these five, each ENABLED.
  assert {
    condition = toset(keys(var.features)) == toset([
      "S3_DATA_EVENTS",
      "EKS_AUDIT_LOGS",
      "EBS_MALWARE_PROTECTION",
      "RDS_LOGIN_EVENTS",
      "LAMBDA_NETWORK_LOGS",
    ])
    error_message = "The default feature set must stay stable across versions."
  }
  assert {
    condition     = alltrue([for f in aws_guardduty_detector_feature.this : f.status == "ENABLED"])
    error_message = "Every default feature must be ENABLED."
  }
}

run "detector_tagged_with_label" {
  command = plan
  assert {
    condition     = one(aws_guardduty_detector.this).tags["Name"] == "dvtca-test-contract"
    error_message = "The detector Name tag must compose namespace-stage-name."
  }
}
