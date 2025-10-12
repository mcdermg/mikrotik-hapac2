config {
  # Enable all rules by default
  disabled_by_default = false

  # Ignore specific rule types if needed
  # ignore_module = [
  #  "module-name"
  # ]
}

# RouterOS provider plugin (if available)
plugin "terraform" {
  enabled = true
  version = "0.7.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

# Core Terraform rules
rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_standard_module_structure" {
  enabled = true
}

rule "terraform_workspace_remote" {
  enabled = true
}
