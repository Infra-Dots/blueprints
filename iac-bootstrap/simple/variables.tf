variable "infradots_token" {
  description = "API token for authenticating with Infradots"
  type        = string
  sensitive   = true
}

variable "organization_name" {
  description = "Name of the IDP organization"
  type        = string
}

