output "detector_id" {
  description = "The GuardDuty detector ID (null when the module is disabled)."
  value       = try(aws_guardduty_detector.this[0].id, null)
}

output "detector_arn" {
  description = "The ARN of the GuardDuty detector (null when the module is disabled)."
  value       = try(aws_guardduty_detector.this[0].arn, null)
}

output "account_id" {
  description = "The AWS account ID the detector belongs to (null when the module is disabled)."
  value       = try(aws_guardduty_detector.this[0].account_id, null)
}
