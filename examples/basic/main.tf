provider "aws" {
  region = "eu-west-1"
}

provider "datadog" {}

module "datadog" {
  source = "../../"

  tags = { Terraform = true }
}
