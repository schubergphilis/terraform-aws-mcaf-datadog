provider "aws" {
  region = "eu-west-1"
}

provider "datadog" {}

# 2 ways of setting up the log forwarder:
# You can provide your existing API key
module "datadog" {
  source = "../../"

  api_key               = "your-api-key"
  install_log_forwarder = true
  tags                  = { Terraform = true }
}

# Or you can let the module create an API key for you
module "datadog_create_api_key" {
  source = "../../"

  api_key_name          = "aws-forwarder-production"
  create_api_key        = true
  install_log_forwarder = true
  tags                  = { Terraform = true }
}
