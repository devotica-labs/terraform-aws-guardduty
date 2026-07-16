# ---------------------------------------------------------------------------
# Provider block — CI-friendly skip flags + non-AWS-shaped placeholder creds.
# ---------------------------------------------------------------------------
provider "aws" {
  region                      = "ap-south-1"
  access_key                  = "not-a-real-aws-key"
  secret_key                  = "not-a-real-aws-secret"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# A production detector with every no-extra-config protection enabled and
# findings exported to a central security-logging S3 bucket, encrypted with a
# customer-managed KMS key (both are required together for finding export).
module "guardduty" {
  source = "../.."

  namespace = "dvtca"
  stage     = "prod"
  name      = "security"

  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"

  # Explicit feature map (mirrors the module default). Runtime monitoring is
  # omitted here because it requires its own additional_configuration block.
  features = {
    S3_DATA_EVENTS         = "ENABLED"
    EKS_AUDIT_LOGS         = "ENABLED"
    EBS_MALWARE_PROTECTION = "ENABLED"
    RDS_LOGIN_EVENTS       = "ENABLED"
    LAMBDA_NETWORK_LOGS    = "ENABLED"
  }

  # Export findings to a central S3 bucket, encrypted with a CMK.
  publishing_s3_arn  = "arn:aws:s3:::dvtca-prod-security-findings"
  publishing_kms_arn = "arn:aws:kms:ap-south-1:111122223333:key/00000000-0000-0000-0000-000000000000"

  tags = {
    Environment = "prod"
    Project     = "terraform-aws-guardduty"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM-OSS"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-guardduty"
  }
}
