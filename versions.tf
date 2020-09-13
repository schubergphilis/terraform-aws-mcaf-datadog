terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    datadog = {
      source = "terraform-providers/datadog"
    }
  }
}
