terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    datadog = {
      source  = "datadog/datadog"
      version = ">= 3.39"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0"
    }
  }
  required_version = ">= 1.9.0"
}
