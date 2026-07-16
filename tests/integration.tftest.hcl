# Integration tests — apply + assert + destroy. Requires real AWS credentials.
# A single GuardDuty detector with its default feature set is cheap to create
# and destroy; teardown removes the detector and its features cleanly.

provider "aws" {
  region = "ap-south-1"
}

variables {
  namespace = "dvtca"
  stage     = "integ"
  name      = "guardduty"

  tags = {
    Environment = "integration-test"
    Ephemeral   = "true"
  }
}

run "apply_and_assert" {
  command = apply

  assert {
    condition     = one(aws_guardduty_detector.this).id != ""
    error_message = "The detector must be created with an ID."
  }
  assert {
    condition     = one(aws_guardduty_detector.this).enable == true
    error_message = "The detector must be enabled after apply."
  }
  assert {
    condition     = length(aws_guardduty_detector_feature.this) == 5
    error_message = "All default features must apply cleanly against the real API."
  }
}
