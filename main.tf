provider "tfe" {
  hostname = var.tfc_host
  token    = var.tfc_token
}

provider "github" {
  token = var.github_token
}


### GITHUB ###

#Repo

resource "github_repository" "demo" {
  name        = "tfc-mondoo-cli"
  description = "LZ for mondoo-cli"
  visibility = "public"
  auto_init = true
}

#Secrets

resource "github_actions_secret" "tfc_token" {
  repository       = github_repository.demo.name
  secret_name      = "TFC_TOKEN"
  plaintext_value  = var.tfc_token
}

resource "github_actions_secret" "tfc_oauth_token" {
  repository       = github_repository.demo.name
  secret_name      = "TFC_OAUTH_TOKEN"
  plaintext_value  = var.oauth_token_id
}

resource "github_actions_secret" "mondoo_token" {
  repository       = github_repository.demo.name
  secret_name      = "MONDOO_CONFIG_BASE64"
  plaintext_value  = var.md_cicd_token
}


#Workflow


resource "github_repository_file" "workflow" {
  repository          = github_repository.demo.name
  branch              = "main"
  file                = ".github/workflows/flow1.yml"
  content             = file("${path.root}/actions/flow1.yml")
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}



#### WORKSPACE ###


resource "tfe_workspace" "demo" {
  name         = "tfc-mondoo-cli"
  organization = var.tfc_org
}

resource "tfe_workspace_settings" "demo-settings" {
  workspace_id   = tfe_workspace.demo.id
  execution_mode = "remote"
}

resource "tfe_variable" "demo" {
  key          = "windows_password"
  value        = var.windows_password
  category     = "terraform"
  workspace_id = tfe_workspace.demo.id
  description  = "Windows RDP PW"
}

resource "tfe_variable" "win_reg_token" {
  key          = "win_reg_token"
  value        = var.win_reg_token
  category     = "terraform"
  workspace_id = tfe_workspace.demo.id
  description  = "Windows Registration Token for Mondoo"
}