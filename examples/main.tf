provider "aws" {}

provider "datadog" {}

module "datadog" {
  source                = "../"
  tags                  = {}
  install_log_forwarder = true
}