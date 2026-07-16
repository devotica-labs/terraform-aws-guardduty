# Plan-only unit tests — no AWS credentials required. Assertions cover
# config-set values and resource cardinality only (computed attributes such as
# detector id/arn are unknown under a mocked provider).

mock_provider "aws" {}

variables {
  namespace = "dvtca"
  stage     = "test"
  name      = "unit"
}

run "detector_planned_by_default" {
  command = plan
  assert {
    condition     = length(aws_guardduty_detector.this) == 1
    error_message = "The detector must be planned when the module is enabled."
  }
  assert {
    condition     = one(aws_guardduty_detector.this).enable == true
    error_message = "The detector must be enabled by default."
  }
  assert {
    condition     = one(aws_guardduty_detector.this).finding_publishing_frequency == "FIFTEEN_MINUTES"
    error_message = "finding_publishing_frequency must default to FIFTEEN_MINUTES."
  }
}

run "no_detector_when_module_disabled" {
  command = plan
  variables {
    enabled = false
  }
  assert {
    condition     = length(aws_guardduty_detector.this) == 0
    error_message = "The detector must not be planned when enabled = false (module no-op)."
  }
  assert {
    condition     = length(aws_guardduty_detector_feature.this) == 0
    error_message = "No features may be planned when the module is a no-op."
  }
}

run "features_count_matches_map" {
  command = plan
  # Default map has five ENABLED features.
  assert {
    condition     = length(aws_guardduty_detector_feature.this) == 5
    error_message = "One detector-feature resource must be planned per entry in var.features."
  }
  assert {
    condition     = alltrue([for f in aws_guardduty_detector_feature.this : f.status == "ENABLED"])
    error_message = "Every default feature must be ENABLED."
  }
}

run "custom_features_map_honored" {
  command = plan
  variables {
    features = {
      S3_DATA_EVENTS      = "ENABLED"
      LAMBDA_NETWORK_LOGS = "DISABLED"
    }
  }
  assert {
    condition     = length(aws_guardduty_detector_feature.this) == 2
    error_message = "Feature count must match the supplied map size."
  }
  assert {
    condition     = aws_guardduty_detector_feature.this["LAMBDA_NETWORK_LOGS"].status == "DISABLED"
    error_message = "A DISABLED feature status must pass through unchanged."
  }
}

run "no_publishing_destination_by_default" {
  command = plan
  assert {
    condition     = length(aws_guardduty_publishing_destination.this) == 0
    error_message = "No publishing destination unless publishing_s3_arn is set."
  }
}

run "publishing_destination_when_arn_set" {
  command = plan
  variables {
    publishing_s3_arn  = "arn:aws:s3:::dvtca-test-findings"
    publishing_kms_arn = "arn:aws:kms:ap-south-1:111122223333:key/00000000-0000-0000-0000-000000000000"
  }
  assert {
    condition     = length(aws_guardduty_publishing_destination.this) == 1
    error_message = "A publishing destination must be planned when publishing_s3_arn is set."
  }
  assert {
    condition     = one(aws_guardduty_publishing_destination.this).destination_arn == "arn:aws:s3:::dvtca-test-findings"
    error_message = "destination_arn must pass through publishing_s3_arn."
  }
  assert {
    condition     = one(aws_guardduty_publishing_destination.this).kms_key_arn == "arn:aws:kms:ap-south-1:111122223333:key/00000000-0000-0000-0000-000000000000"
    error_message = "kms_key_arn must pass through publishing_kms_arn."
  }
}

run "detector_can_be_suspended" {
  command = plan
  variables {
    enable = false
  }
  # The detector still exists (count 1) but is suspended (enable = false).
  assert {
    condition     = length(aws_guardduty_detector.this) == 1
    error_message = "A suspended detector must still be planned."
  }
  assert {
    condition     = one(aws_guardduty_detector.this).enable == false
    error_message = "enable = false must suspend the detector."
  }
}
