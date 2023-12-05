provider "aws" {
  region = "eu-west-1"
}

provider "datadog" {}

module "datadog" {
  #checkov:skip=CKV_TF_1: Irrelevant for this example
  source = "../../"

  install_log_forwarder = true
  tags                  = { Terraform = true }
}
