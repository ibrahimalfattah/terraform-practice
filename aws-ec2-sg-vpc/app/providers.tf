# =============================================================================
# providers.tf – Provider Configuration
# =============================================================================
# A provider is a plugin that knows how to communicate with a specific API
# (in this case, AWS).  This file configures the AWS provider that was
# declared in versions.tf.
#
# SEPARATION OF CONCERNS
# ----------------------
# It is best practice to keep version constraints in versions.tf and
# provider *configuration* (credentials, region, etc.) here.  That way
# versions.tf stays environment-agnostic while this file can be swapped
# per workspace/environment.
# =============================================================================

# -----------------------------------------------------------------------------
# provider "aws"
# -----------------------------------------------------------------------------
# Tells the AWS provider which region to send API requests to.
#
# region – resolved from the `aws_region` variable declared in variables.tf
#           and set in terraform.tfvars (e.g. "eu-north-1").
#           Changing this value and re-applying would deploy resources into a
#           different AWS region.
#
# CREDENTIALS (not shown here)
# ----------------------------
# The provider reads AWS credentials from the standard credential chain:
#   1. Environment variables:  AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY
#   2. Shared credential file: ~/.aws/credentials
#   3. IAM instance/role profile (useful in CI or on EC2)
# You can also add `profile = "my-profile"` here to use a named profile.
# -----------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region
}
