provider "aws" {
  region = "eu-west-1"
}

provider "datadog" {}

module "datadog" {
  source = "../../"

  install_log_forwarder = true
  tags                  = { Terraform = true }
}
