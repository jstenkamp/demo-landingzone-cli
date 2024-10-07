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
  name        = var.tfc_workspace
  description = "LZ for ${var.tfc_workspace}"
  visibility = "public"
  auto_init = true
}

resource "github_repository_file" "terraform" {
  repository          = github_repository.demo.name
  branch              = "main"
  file                = "terraform.tf"
  content             = <<-EOF
  terraform { 
  cloud { 
    
    organization = "${var.tfc_org}" 

    workspaces { 
      name = "${var.tfc_workspace}" 
      } 
    } 
  }
  EOF
  commit_message      = "Managed by Terraform"
  commit_author       = "Landingzone Admin"
  commit_email        = "lz@example.com"
  overwrite_on_create = true
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

#Variables

resource "github_actions_variable" "workspace" {
  repository       = github_repository.demo.name
  variable_name    = "TFC_WORKSPACE"
  value            = var.tfc_workspace
}

resource "github_actions_variable" "org" {
  repository       = github_repository.demo.name
  variable_name    = "TFC_ORG"
  value            = var.tfc_org
}

#Workflow


resource "github_repository_file" "workflow" {
  repository          = github_repository.demo.name
  branch              = "main"
  file                = ".github/workflows/flow1.yml"
  content             = file("${path.root}/actions/flow1.yml")
  commit_message      = "Managed by Terraform"
  commit_author       = "Landinzone Admin"
  commit_email        = "lz@example.com"
  overwrite_on_create = true
}



#### WORKSPACE ###


resource "tfe_workspace" "demo" {
  name         = var.tfc_workspace
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