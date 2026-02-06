variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "node_instance_types" {
  description = "List of instance types for the EKS managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "domain_name" {
  description = "Domain name for the EKS cluster (used by external-dns)"
  type        = string
  default     = "example.com"
}
