# Cloud & DevOps Tools

Complete setup for cloud development and DevOps operations.

## Prerequisites

- [System Setup](01-system-setup.md) completed
- Homebrew installed

## 1. AWS CLI

Amazon Web Services command-line interface.

```bash
# Install AWS CLI v2
brew install awscli

# Verify installation
aws --version

# Configure AWS CLI
aws configure

# Enter when prompted:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-east-1)
# - Default output format (json)

# Test configuration
aws sts get-caller-identity
```

### AWS CLI Usage

```bash
# S3 operations
aws s3 ls
aws s3 cp file.txt s3://bucket-name/
aws s3 sync ./local-dir s3://bucket-name/remote-dir

# EC2 operations
aws ec2 describe-instances
aws ec2 start-instances --instance-ids i-1234567890abcdef0
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Lambda operations
aws lambda list-functions
aws lambda invoke --function-name my-function output.json
```

## 2. AWS SAM CLI

AWS Serverless Application Model for Lambda development.

```bash
# Install AWS SAM CLI
brew install aws-sam-cli

# Verify installation
sam --version

# Initialize new project
sam init

# Build application
sam build

# Deploy application
sam deploy --guided
```

## 3. AWS CDK

AWS Cloud Development Kit for Infrastructure as Code.

```bash
# Install AWS CDK
npm install -g aws-cdk

# Verify installation
cdk --version

# Initialize new project
cdk init app --language typescript

# Deploy stack
cdk deploy

# Destroy stack
cdk destroy
```

## 4. Terraform

Infrastructure as Code tool supporting multiple cloud providers.

```bash
# Install Terraform
brew install terraform

# Verify installation
terraform --version

# Initialize Terraform project
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

### Terraform Example

```hcl
# main.tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-example-bucket"
  
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
```

## 5. Terragrunt

Terraform wrapper for DRY configurations.

```bash
# Install Terragrunt
brew install terragrunt

# Verify installation
terragrunt --version

# Run Terraform commands through Terragrunt
terragrunt plan
terragrunt apply
```

## 6. Ansible

Configuration management and automation.

```bash
# Install Ansible
brew install ansible

# Verify installation
ansible --version

# Run playbook
ansible-playbook playbook.yml

# Run ad-hoc command
ansible all -m ping
```

## 7. Vagrant

Development environment management.

```bash
# Install Vagrant
brew install vagrant

# Verify installation
vagrant --version

# Initialize Vagrant
vagrant init ubuntu/focal64

# Start VM
vagrant up

# SSH into VM
vagrant ssh

# Stop VM
vagrant halt

# Destroy VM
vagrant destroy
```

## 8. Additional DevOps Tools

### Prometheus (Monitoring)

```bash
# Install Prometheus
brew install prometheus

# Start Prometheus
prometheus --config.file=/opt/homebrew/etc/prometheus.yml

# Access UI at http://localhost:9090
```

### Grafana (Visualization)

```bash
# Install Grafana
brew install grafana

# Start Grafana
brew services start grafana

# Access UI at http://localhost:3000
# Default login: admin/admin
```

## 9. CI/CD Tools

### GitHub Actions

Already integrated if using GitHub. Configure in `.github/workflows/`.

### Jenkins

```bash
# Install Jenkins
brew install jenkins-lts

# Start Jenkins
brew services start jenkins-lts

# Access at http://localhost:8080
```

## 10. Best Practices

### 1. Use IAM Roles

Don't commit AWS credentials. Use IAM roles for EC2/Lambda.

### 2. Infrastructure as Code

Always use Terraform/CDK instead of manual console changes.

### 3. State Management

```bash
# Use remote state for Terraform
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### 4. Version Everything

Pin versions in IaC:
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
```

## Next Steps

Continue with:
- **[Docker & Kubernetes](05-docker-kubernetes.md)** - Container orchestration
- **[Security & Monitoring](13-security-monitoring.md)** - Secure your infrastructure

---

**Estimated Time**: 30 minutes  
**Difficulty**: Intermediate to Advanced  
**Last Updated**: October 5, 2025
