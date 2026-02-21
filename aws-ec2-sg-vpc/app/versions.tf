# =============================================================================
# versions.tf – Terraform & Provider Version Constraints
# =============================================================================
# This file pins the minimum version of Terraform core and declares which
# providers are required, along with their acceptable version ranges.
#
# WHY THIS FILE EXISTS
# ---------------------
# Without explicit constraints, `terraform init` would download whatever
# the latest provider version is at that moment, which can break configs when
# providers release breaking changes.  Pinning here gives reproducible,
# predictable runs across machines and CI pipelines.
#
# UPGRADING
# ---------
# After changing a version constraint, run:
#   terraform init -upgrade
# to download the new version and update .terraform.lock.hcl accordingly.
# =============================================================================

terraform {
  # ---------------------------------------------------------------------------
  # required_version
  # ---------------------------------------------------------------------------
  # Terraform core must be at least 1.5.0.  The ">=" operator means any
  # version ≥ 1.5.0 is accepted (e.g. 1.5.7, 1.7.0, 1.9.0).
  # 1.5.0 introduced the `import` block and other QoL improvements used here.
  # If a team member runs an older version they will get a clear error message
  # instead of a silent misbehaviour.
  # ---------------------------------------------------------------------------
  required_version = ">= 1.5.0"

  required_providers {
    # -------------------------------------------------------------------------
    # aws provider
    # -------------------------------------------------------------------------
    # The official HashiCorp AWS provider that translates Terraform HCL into
    # AWS API calls (creates VPCs, EC2 instances, security groups, etc.).
    #
    # source  – registry address: registry.terraform.io/hashicorp/aws
    # version – "~> 5.0" is a pessimistic constraint meaning:
    #             any version ≥ 5.0 AND < 6.0
    #           This allows automatic patch/minor updates (5.1, 5.99) while
    #           preventing a breaking major-version jump to 6.x.
    # -------------------------------------------------------------------------
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
