# InfraDots Organization Bootstrap

Terraform configuration to bootstrap an InfraDots organization with multiple environment workspaces and AWS credentials from 1Password.

## Overview

This blueprint creates:
- An InfraDots organization
- Three workspaces (dev, stage, prod)
- AWS credentials for each environment, fetched from 1Password
- Environment variables for AWS access in the organization

## Prerequisites

- Terraform/OpenTofu >= 1.5.0
- InfraDots account and API token
- 1Password account with service account token
- AWS credentials stored in 1Password

## 1Password Setup

Store your AWS credentials in 1Password with the following structure:

**Item Names (default):**
- `AWS Dev Credentials`
- `AWS Stage Credentials`
- `AWS Prod Credentials`

**Fields required:**
- `credential` - AWS Access Key ID
- `password` - AWS Secret Access Key

You can customize these names in `terraform.tfvars`.

## Usage

### 1. Set Environment Variables

```bash
export INFRADOTS_TOKEN="your-infradots-token"
export OP_SERVICE_ACCOUNT_TOKEN="your-1password-service-account-token"
```

### 2. Create terraform.tfvars

```hcl
organization_name = "my-org"
execution_mode    = "Remote"
agents_enabled    = true
onepassword_vault = "Infrastructure"

# Optional: Override default AWS credential item names
aws_credentials = {
  dev = {
    item_name        = "AWS Dev Credentials"
    access_key_field = "access_key_id"
    secret_key_field = "secret_access_key"
    description      = "AWS credentials for development environment"
  }
  stage = {
    item_name        = "AWS Stage Credentials"
    access_key_field = "access_key_id"
    secret_key_field = "secret_access_key"
    description      = "AWS credentials for staging environment"
  }
  prod = {
    item_name        = "AWS Prod Credentials"
    access_key_field = "access_key_id"
    secret_key_field = "secret_access_key"
    description      = "AWS credentials for production environment"
  }
}

# Optional: Customize workspace configuration
workspace_config = {
  dev = {
    description       = "Development environment workspace"
    source           = "https://github.com/your-org/terraform-config"
    branch           = "develop"
    terraform_version = "1.5.0"
  }
  stage = {
    description       = "Staging environment workspace"
    source           = "https://github.com/your-org/terraform-config"
    branch           = "staging"
    terraform_version = "1.5.0"
  }
  prod = {
    description       = "Production environment workspace"
    source           = "https://github.com/your-org/terraform-config"
    branch           = "main"
    terraform_version = "1.5.0"
  }
}
```

### 3. Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

After successful apply, you'll get:

- `organization_id` - The UUID of the created organization
- `organization_name` - The name of the organization
- `workspace_ids` - Map of workspace names to their UUIDs
- `workspace_names` - List of created workspace names
- `aws_credential_variables` - Map showing the variable keys created for AWS credentials

## AWS Credential Variables

The configuration creates the following environment variables at the organization level:

- `AWS_ACCESS_KEY_ID_DEV`
- `AWS_SECRET_ACCESS_KEY_DEV`
- `AWS_ACCESS_KEY_ID_STAGE`
- `AWS_SECRET_ACCESS_KEY_STAGE`
- `AWS_ACCESS_KEY_ID_PROD`
- `AWS_SECRET_ACCESS_KEY_PROD`

These can be referenced in your workspace Terraform configurations using the appropriate suffix for each environment.

## Customization

### Add More Environments

To add additional environments, extend the `workspace_config` and `aws_credentials` maps in your `terraform.tfvars`:

```hcl
workspace_config = {
  dev   = { ... }
  stage = { ... }
  prod  = { ... }
  qa    = {
    description       = "QA environment workspace"
    source           = "https://github.com/your-org/terraform-config"
    branch           = "qa"
    terraform_version = "1.5.0"
  }
}

aws_credentials = {
  dev   = { ... }
  stage = { ... }
  prod  = { ... }
  qa    = {
    item_name        = "AWS QA Credentials"
    access_key_field = "access_key_id"
    secret_key_field = "secret_access_key"
    description      = "AWS credentials for QA environment"
  }
}
```

## Security Considerations

- Never commit `terraform.tfvars` containing sensitive data to version control
- Use environment variables for tokens
- Store AWS credentials securely in 1Password
- Use 1Password service accounts with minimal required permissions
- All credential values are marked as sensitive in Terraform state

## Troubleshooting

### 1Password Authentication Issues

```bash
# Verify 1Password CLI is installed
op --version

# Verify service account token
op vault list
```

### InfraDots API Issues

```bash
# Test API connectivity
curl -H "Authorization: Bearer $INFRADOTS_TOKEN" https://api.infradots.com/api/v1/organizations
```

## References

- [InfraDots Provider Documentation](https://search.opentofu.org/provider/infra-dots/infradots/latest)
- [1Password Provider Documentation](https://registry.terraform.io/providers/1Password/onepassword/latest/docs)
- [Terraform Provider GitHub Repository](https://github.com/infra-dots/terraform-provider-infradots)
