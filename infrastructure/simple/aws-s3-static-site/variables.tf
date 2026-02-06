variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Name of the project to prefix resources"
  type        = string
  default     = "infradots-site"
}
