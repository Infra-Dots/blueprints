# Create the organization
resource "infradots_organization" "org" {
  name           = var.organization_name
  execution_mode = var.execution_mode
  agents_enabled = var.agents_enabled
}

# Create workspaces for each environment
resource "infradots_workspace" "workspaces" {
  for_each = var.workspace_config

  organization_name = infradots_organization.org.name
  name              = each.key
  description       = each.value.description
  source            = each.value.source
  branch            = each.value.branch
  terraform_version = each.value.terraform_version

  depends_on = [infradots_organization.org]
}

# Fetch AWS credentials from 1Password
data "onepassword_item" "aws_credentials" {
  for_each = var.aws_credentials

  vault = var.onepassword_vault
  title = each.value.item_name
}

# Create AWS_ACCESS_KEY_ID variables for each environment
resource "infradots_variable" "aws_access_key" {
  for_each = var.aws_credentials

  organization_name = infradots_organization.org.name
  key               = "AWS_ACCESS_KEY_ID_${upper(each.key)}"
  value             = data.onepassword_item.aws_credentials[each.key].credential
  description       = "${each.value.description} - Access Key ID"
  category          = "env"
  sensitive         = true

  depends_on = [infradots_workspace.workspaces]
}

# Create AWS_SECRET_ACCESS_KEY variables for each environment
resource "infradots_variable" "aws_secret_key" {
  for_each = var.aws_credentials

  organization_name = infradots_organization.org.name
  key               = "AWS_SECRET_ACCESS_KEY_${upper(each.key)}"
  value             = data.onepassword_item.aws_credentials[each.key].password
  description       = "${each.value.description} - Secret Access Key"
  category          = "env"
  sensitive         = true

  depends_on = [infradots_workspace.workspaces]
}
