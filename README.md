# terraform-practice

A hands-on Terraform project for practicing reusable **AWS module** authoring.

## Architecture

```
Root module
├── modules/vpc   — VPC, subnets (public + private), IGW, route tables
├── modules/ec2   — EC2 instance + security group
└── modules/s3    — S3 bucket with versioning, encryption & lifecycle rules
```

Resources created when you run `terraform apply`:

| Resource | Details |
|---|---|
| VPC | Custom CIDR, DNS enabled |
| Public subnets | One per AZ, auto-assign public IP |
| Private subnets | One per AZ |
| Internet Gateway | Attached to VPC |
| Route tables | Separate public / private |
| EC2 instance | Amazon Linux 2023, gp3 root volume, encrypted |
| Security group | HTTP 80, HTTPS 443, optional SSH |
| S3 bucket | Versioning, AES-256 encryption, public-access block, lifecycle |

## Prerequisites

| Tool | Version |
|---|---|
| Terraform | ≥ 1.6 |
| AWS CLI | ≥ 2.x (configured with credentials) |

## Quick Start

```bash
# 1. Initialise — download provider & modules
terraform init

# 2. Preview changes
terraform plan

# 3. Apply (will prompt for confirmation)
terraform apply

# 4. Destroy when done
terraform destroy
```

## Configuration

All tuneable settings live in `terraform.tfvars`. Key variables:

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `us-east-1` | Target AWS region |
| `project_name` | `tf-practice` | Prefix for every resource name |
| `environment` | `dev` | Stage tag (dev / staging / prod) |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR |
| `instance_type` | `t3.micro` | EC2 instance type |
| `ami_id` | Amazon Linux 2023 | AMI ID |
| `key_pair_name` | _(empty)_ | Set to enable SSH |
| `enable_versioning` | `true` | S3 versioning |

## Module Reference

### `modules/vpc`
Creates a VPC with configurable public and private subnets spread across
multiple AZs, an Internet Gateway, and separate route tables for each tier.

### `modules/ec2`
Launches a single EC2 instance into a specified subnet. Attaches a security
group allowing HTTP/HTTPS inbound (and optionally SSH if a key pair is provided).

### `modules/s3`
Provisions an S3 bucket with public-access blocking, optional versioning,
AES-256 server-side encryption, and a lifecycle rule to expire old versions
after 90 days.

## Project Structure

```
.
├── main.tf              # Root module — calls each child module
├── variables.tf         # Root input variables
├── outputs.tf           # Root outputs
├── providers.tf         # AWS provider + Terraform version constraints
├── terraform.tfvars     # Variable values (edit before applying)
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── s3/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```
