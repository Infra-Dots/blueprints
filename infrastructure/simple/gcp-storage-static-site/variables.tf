variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "region" {
  description = "The region to deploy to"
  type        = string
  default     = "us-central1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "static-site"
}
