terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    datadog = {
      source  = "datadog/datadog"
      version = ">= 3.82"
    }
  }
  required_version = ">= 1.9.0"
}
