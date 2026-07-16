output "detector_id" {
  description = "The GuardDuty detector ID."
  value       = module.guardduty.detector_id
}

output "detector_arn" {
  description = "The GuardDuty detector ARN."
  value       = module.guardduty.detector_arn
}

output "account_id" {
  description = "The AWS account ID the detector belongs to."
  value       = module.guardduty.account_id
}
