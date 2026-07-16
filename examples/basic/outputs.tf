output "detector_id" {
  description = "The GuardDuty detector ID."
  value       = module.guardduty.detector_id
}

output "detector_arn" {
  description = "The GuardDuty detector ARN."
  value       = module.guardduty.detector_arn
}
