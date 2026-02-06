terraform {
  required_version = ">= 1.5.0"

  required_providers {
    infradots = {
      source  = "infra-dots/infradots"
      version = "~> 1.1.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.0"
    }
  }
}

provider "infradots" {
  # token is expected to be set via INFRADOTS_TOKEN environment variable
  # or passed as a variable
  token = var.infradots_token
}

provider "onepassword" {
  # Uses OP_SERVICE_ACCOUNT_TOKEN environment variable for authentication
}
