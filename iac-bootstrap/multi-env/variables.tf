variable "infradots_token" {
  description = "API token for authenticating with Infradots"
  type        = string
  sensitive   = true
}

variable "organization_name" {
  description = "Name of the organization to create"
  type        = string
}

variable "execution_mode" {
  description = "Execution mode for the organization (Remote or Local)"
  type        = string
  default     = "Remote"
}

variable "agents_enabled" {
  description = "Whether agents are enabled for the organization"
  type        = bool
  default     = true
}

variable "onepassword_vault" {
  description = "1Password vault name containing AWS credentials"
  type        = string
}

variable "aws_credentials" {
  description = "Map of workspace names to their 1Password item names for AWS credentials"
  type = map(object({
    item_name         = string
    access_key_field  = string
    secret_key_field  = string
    description       = string
  }))
  default = {
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
}

variable "workspace_config" {
  description = "Configuration for workspaces"
  type = map(object({
    description       = string
    source           = string
    branch           = string
    terraform_version = string
  }))
  default = {
    dev = {
      description       = "Development environment workspace"
      source           = "https://github.com/example/terraform-config"
      branch           = "develop"
      terraform_version = "1.5.0"
    }
    stage = {
      description       = "Staging environment workspace"
      source           = "https://github.com/example/terraform-config"
      branch           = "staging"
      terraform_version = "1.5.0"
    }
    prod = {
      description       = "Production environment workspace"
      source           = "https://github.com/example/terraform-config"
      branch           = "main"
      terraform_version = "1.5.0"
    }
  }
}
