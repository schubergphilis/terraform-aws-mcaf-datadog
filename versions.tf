terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    datadog = {
      source = "datadog/datadog"
    }
  }
  required_version = ">= 0.13"
}
