terraform {
  required_version = ">= 1.5.0"

  required_providers {
    infradots = {
      source = "local/infra-dots/infradots"
      #source  = "infra-dots/infradots"
      version = "~> 1.2.2"
    }
  }
}

provider "infradots" {
  # token is expected to be set via INFRADOTS_TOKEN environment variable
  # or passed as a variable
  token = var.infradots_token
}
