output "organization_id" {
  description = "The ID of the created organization"
  value       = infradots_organization.org.id
}

output "organization_name" {
  description = "The name of the created organization"
  value       = infradots_organization.org.name
}

output "workspace_ids" {
  description = "Map of workspace names to their IDs"
  value = {
    for k, ws in infradots_workspace.workspaces : k => ws.id
  }
}

output "workspace_names" {
  description = "List of created workspace names"
  value       = [for ws in infradots_workspace.workspaces : ws.name]
}

output "aws_credential_variables" {
  description = "Map of environment names to their AWS credential variable keys"
  value = {
    for env in keys(var.aws_credentials) : env => {
      access_key_id     = "AWS_ACCESS_KEY_ID_${upper(env)}"
      secret_access_key = "AWS_SECRET_ACCESS_KEY_${upper(env)}"
    }
  }
}
