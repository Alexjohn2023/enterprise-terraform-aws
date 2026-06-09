# Enterprise Terraform AWS — Multi-Account Infrastructure
## AWS Organizations + HCP Terraform Cloud + GitOps Pipeline

![Terraform](https://img.shields.io/badge/Terraform-v1.15.5-7B42BC?style=flat&logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Multi--Account-FF9900?style=flat&logo=amazonaws)
![HCP Terraform](https://img.shields.io/badge/HCP_Terraform-Cloud-7B42BC?style=flat&logo=terraform)
![GitHub Actions](https://img.shields.io/badge/GitOps-VCS_Driven-2088FF?style=flat&logo=github)

> Enterprise-grade AWS infrastructure using AWS Organizations, Service Control Policies, Terraform modules, and HCP Terraform Cloud — the pattern RTP companies like TCS, KPMG, Deloitte, and Duke Health are running in production.

---

## 🏗️ Architecture

```
AWS Organization (o-zw42bg7uh1)
│
├── OU: NonProduction
│   ├── SCPs: DenyRootAccess + AllowedRegionsOnly
│   ├── enterprise-dev     (443628962352)
│   │   └── VPC + EC2 + S3 + IAM
│   └── enterprise-staging (145554226524)
│       └── VPC + EC2 + S3 + IAM
│
└── OU: Production
    ├── SCPs: DenyRootAccess + AllowedRegionsOnly + RequireEncryption
    └── enterprise-prod    (474025757486)
        └── VPC + EC2 + S3 + IAM

HCP Terraform Cloud (alexcrh)
└── Project: enterprise-aws-infra
    ├── Workspace: enterprise-dev     → environments/dev
    ├── Workspace: enterprise-staging → environments/staging
    └── Workspace: enterprise-prod   → environments/prod

GitHub: Alexjohn2023/enterprise-terraform-aws
└── VCS-driven workflow — push triggers automatic plan
```

---

## 📁 Project Structure

```
enterprise-terraform-aws/
├── environments/
│   ├── dev/
│   │   ├── main.tf        # Module calls
│   │   ├── variables.tf   # Dev-specific values
│   │   ├── outputs.tf     # VPC, EC2, S3 outputs
│   │   ├── provider.tf    # AWS provider + default tags
│   │   └── backend.tf     # HCP Terraform Cloud backend
│   ├── staging/           # Same structure, staging values
│   └── prod/              # Same structure, prod values
├── modules/
│   ├── networking/        # VPC, Subnet, IGW, Route Tables
│   ├── compute/           # EC2, Security Group, AMI lookup
│   └── storage/           # S3, Encryption, Versioning, Access Block
├── policies/
│   ├── scp-deny-root.json
│   ├── scp-allowed-regions.json
│   └── scp-require-encryption.json
└── README.md
```

---

## 🚀 What Was Deployed

| Environment | Account ID | Instance | VPC | S3 Bucket |
|---|---|---|---|---|
| dev | 443628962352 | t3.micro | 10.0.0.0/16 | enterprise-app-dev-443628962352 |
| staging | 145554226524 | t3.small | 10.1.0.0/16 | enterprise-app-staging-145554226524 |
| prod | 474025757486 | t3.medium | 10.2.0.0/16 | enterprise-app-prod-474025757486 |

---

## 🔐 Security Best Practices Implemented

### 1. AWS Organizations + SCPs

| SCP | Applied To | What It Does |
|---|---|---|
| DenyRootAccess | All OUs | Blocks root account usage |
| AllowedRegionsOnly | All OUs | Restricts to us-east-1 and us-east-2 |
| RequireEncryption | Production only | Requires AES256 on all S3 objects |

### 2. Separate AWS Accounts Per Environment
- Dev mistakes **cannot** affect production
- Separate billing per environment
- Independent IAM boundaries

### 3. Encrypted Remote State Per Account
```
enterprise-dev     → S3: enterprise-tfstate-dev-2026
enterprise-staging → S3: enterprise-tfstate-staging-2026
enterprise-prod    → S3: enterprise-tfstate-prod-2026
```
Each bucket: AES256 encrypted + versioning + public access blocked

### 4. Dedicated IAM Users Per Workspace
```
terraform-cloud-dev     → PowerUserAccess → enterprise-dev account only
terraform-cloud-staging → PowerUserAccess → enterprise-staging account only
terraform-cloud-prod    → PowerUserAccess → enterprise-prod account only
```

### 5. Mandatory Tagging on All Resources
```hcl
default_tags {
  tags = {
    Environment = var.environment
    Project     = "enterprise-terraform-aws"
    ManagedBy   = "Terraform"
    Owner       = "Alexander Njoku"
    CostCenter  = "CloudEngineering"
  }
}
```

---

## 🔄 GitOps Workflow

```
Developer pushes code to GitHub
          ↓
Terraform Cloud detects change (VCS trigger)
          ↓
Plan runs REMOTELY on Terraform Cloud
          ↓
Cost estimation calculated automatically
          ↓
Team reviews plan in Terraform Cloud UI
          ↓
Manual approval required (prod)
          ↓
terraform apply runs remotely
          ↓
Infrastructure updated in correct AWS account
```

---

## 🏁 How to Use This Project

### Prerequisites
- AWS CLI configured with Organizations management access
- Terraform CLI v1.5+
- HCP Terraform account
- GitHub account

### Step 1 — Set Up AWS Organization
```bash
aws organizations create-organization --feature-set ALL

# Create OUs
aws organizations create-organizational-unit \
  --parent-id <root-id> --name "NonProduction"

aws organizations create-organizational-unit \
  --parent-id <root-id> --name "Production"
```

### Step 2 — Create Member Accounts
```bash
aws organizations create-account \
  --email your+dev@gmail.com \
  --account-name "enterprise-dev"
```

### Step 3 — Apply SCPs
```bash
aws organizations create-policy \
  --name "DenyRootAccess" \
  --type SERVICE_CONTROL_POLICY \
  --content file://policies/scp-deny-root.json

aws organizations attach-policy \
  --policy-id <policy-id> \
  --target-id <ou-id>
```

### Step 4 — Create Remote State Per Account
```bash
# Assume role into each account
aws sts assume-role \
  --role-arn arn:aws:iam::<account-id>:role/OrganizationAccountAccessRole \
  --role-session-name setup-session

# Create S3 + DynamoDB per account
aws s3api create-bucket --bucket enterprise-tfstate-dev-2026 --region us-east-1
```

### Step 5 — Connect HCP Terraform
1. Create project `enterprise-aws-infra` in HCP Terraform
2. Create workspaces: `enterprise-dev`, `enterprise-staging`, `enterprise-prod`
3. Add AWS credentials as environment variables per workspace
4. Connect each workspace to GitHub repo with correct working directory

### Step 6 — Push and Deploy
```bash
git push origin main
# Terraform Cloud automatically triggers plan
```

---

## 💰 Estimated Monthly Cost

| Resource | Cost |
|---|---|
| EC2 t3.micro (dev) | ~$7.59/mo |
| EC2 t3.small (staging) | ~$15.18/mo |
| EC2 t3.medium (prod) | ~$30.37/mo |
| S3 (3 buckets) | ~$0.10/mo |
| **Total** | **~$53/mo** |

> 🔴 Run teardown when not in use to avoid charges.

---

## 🧹 Teardown

```bash
# Assume role into each account and destroy
cd environments/dev && terraform destroy -auto-approve
cd environments/staging && terraform destroy -auto-approve
cd environments/prod && terraform destroy -auto-approve

# Delete S3 state buckets
aws s3 rb s3://enterprise-tfstate-dev-2026 --force
aws s3 rb s3://enterprise-tfstate-staging-2026 --force
aws s3 rb s3://enterprise-tfstate-prod-2026 --force
```

---

## 📖 Full Article

Read the complete walkthrough on Medium:
[Enterprise Terraform AWS — Multi-Account Infrastructure with AWS Organizations and HCP Terraform](https://medium.com/@alex2020global)

---

## 👤 Author

**Alexander Njoku** — Cloud & DevOps Engineer | Raleigh, NC

- 🌍 Portfolio: [zandersworldview.com](https://zandersworldview.com)
- 💼 LinkedIn: [linkedin.com/in/alexander-njoku-62040a194](https://linkedin.com/in/alexander-njoku-62040a194)
- ✍️ Medium: [medium.com/@alex2020global](https://medium.com/@alex2020global)
- 💻 GitHub: [github.com/Alexjohn2023](https://github.com/Alexjohn2023)