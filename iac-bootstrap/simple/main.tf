locals {
  workspaces = {
    dev = {
      source = "Infra-Dots/blueprints/dev"
      description = "Blueprints dev workspace"
      account_id = "idp-gcp-dev-acc"
    }
    prod = {
      source = "Infra-Dots/blueprints/prod"
      description = "Blueprints prod workspace"
      account_id = "idp-gcp-prod-acc"
    }
  }
}

resource "infradots_vcs" "github" {
  organization_name = var.organization_name
  name              = "github_tofu"
  vcs_type          = "github"
  url               = "https://github.com"
  client_id         = "ghp_your_github_token"
  client_secret     = "gh_client_secret"
  description       = "GitHub VCS connection for our organization"
}

resource "infradots_workspace" "workspaces" {
  for_each = local.workspaces

  organization_name = var.organization_name
  name              = each.key
  description       = each.value.description
  source            = each.value.source
  branch            = lookup(each.value, "branch", "main")
  terraform_version = lookup(each.value, "tf_version", "1.10.7")
  depends_on        = [infradots_vcs.github]
}

resource "infradots_variable" "env" {
  for_each = local.workspaces

  key = "env"
  value = each.key
  organization_name = var.organization_name
  workspace = infradots_workspace.workspaces[each.key].id
}

resource "infradots_variable" "account_id" {
  for_each = local.workspaces

  key = "account_id"
  value = each.value.account_id
  organization_name = var.organization_name
  workspace = infradots_workspace.workspaces[each.key].id
}
