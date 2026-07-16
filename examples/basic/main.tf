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

# Uses local path during development.
# Change to Registry source after first release:
#   source  = "devotica-labs/guardduty/aws"
#   version = "~> 0.1"

module "guardduty" {
  source = "../.."

  # Detector name/tags compose to: dvtca-sandbox-security
  namespace = "dvtca"
  stage     = "sandbox"
  name      = "security"

  # Fintech defaults cover the rest: the detector is enabled, findings publish
  # every FIFTEEN_MINUTES, and every protection feature that needs no extra
  # configuration is ENABLED (S3 data events, EKS audit logs, EBS malware
  # protection, RDS login events, Lambda network logs).

  tags = {
    Environment = "sandbox"
    Project     = "terraform-aws-guardduty"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM-OSS"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-guardduty"
  }
}
