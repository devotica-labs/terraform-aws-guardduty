# ---------------------------------------------------------------------------
# Detector
# ---------------------------------------------------------------------------
variable "enable" {
  type        = bool
  description = "Whether the GuardDuty detector is active. true (default) turns threat detection on; false creates a suspended detector. Distinct from the module-level `enabled`, which is a create-nothing no-op switch."
  default     = true
}

variable "finding_publishing_frequency" {
  type        = string
  description = "How often GuardDuty publishes updated findings: FIFTEEN_MINUTES (fintech default — fastest), ONE_HOUR, or SIX_HOURS. Ignored for member accounts (the delegated admin controls it)."
  default     = "FIFTEEN_MINUTES"

  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.finding_publishing_frequency)
    error_message = "finding_publishing_frequency must be one of: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."
  }
}

# ---------------------------------------------------------------------------
# Protection features
# ---------------------------------------------------------------------------
variable "features" {
  type        = map(string)
  description = "Map of GuardDuty detector-feature name to status (ENABLED or DISABLED). Defaults enable every protection that needs no additional_configuration block. Runtime-monitoring features (EKS_RUNTIME_MONITORING, RUNTIME_MONITORING) require their own additional_configuration and are intentionally omitted from the default; add them here only alongside that configuration."
  default = {
    S3_DATA_EVENTS         = "ENABLED"
    EKS_AUDIT_LOGS         = "ENABLED"
    EBS_MALWARE_PROTECTION = "ENABLED"
    RDS_LOGIN_EVENTS       = "ENABLED"
    LAMBDA_NETWORK_LOGS    = "ENABLED"
  }

  validation {
    condition     = length([for s in values(var.features) : s if !contains(["ENABLED", "DISABLED"], s)]) == 0
    error_message = "Every features value must be either ENABLED or DISABLED."
  }
}

# ---------------------------------------------------------------------------
# Finding export (publishing destination)
# ---------------------------------------------------------------------------
variable "publishing_s3_arn" {
  type        = string
  description = "ARN of the S3 bucket that GuardDuty exports findings to. Null (default) disables finding export. When set, publishing_kms_arn must also be supplied."
  default     = null

  validation {
    condition     = var.publishing_s3_arn == null || can(regex("^arn:aws[a-z-]*:s3:", var.publishing_s3_arn))
    error_message = "publishing_s3_arn must be an S3 bucket ARN (arn:aws*:s3:...) or null."
  }
}

variable "publishing_kms_arn" {
  type        = string
  description = "ARN of the customer-managed KMS key GuardDuty uses to encrypt exported findings. Required when publishing_s3_arn is set."
  default     = null

  validation {
    condition     = var.publishing_kms_arn == null || can(regex("^arn:aws[a-z-]*:kms:", var.publishing_kms_arn))
    error_message = "publishing_kms_arn must be a KMS key ARN (arn:aws*:kms:...) or null."
  }

  validation {
    condition     = var.publishing_s3_arn == null || var.publishing_kms_arn != null
    error_message = "publishing_kms_arn is required when publishing_s3_arn is set (GuardDuty encrypts exported findings with a customer-managed key)."
  }
}
