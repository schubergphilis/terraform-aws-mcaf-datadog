run "setup" {
  module {
    source = "./tests/setup"
  }
}

mock_provider "datadog" {}

mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  override_data {
    target = data.aws_iam_policy_document.datadog_integration_policy
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":[\"*\"],\"Resource\":\"*\",\"Effect\":\"Allow\"}]}"
    }
  }

  override_data {
    target = data.aws_iam_policy_document.datadog_resource_collection_policy
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":[\"*\"],\"Resource\":\"*\",\"Effect\":\"Allow\"}]}"
    }
  }
}

run "install_log_forwarder" {

  variables {
    install_log_forwarder = true
    api_key               = "1234567890"
  }

  override_data {
    target = data.http.datadog_forwarder_yaml_url
    values = {
      response_body = "test"
    }
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = resource.datadog_integration_aws_lambda_arn.default[0] != null
    error_message = "The log forwarder was not installed"
  }

  assert {
    condition     = resource.aws_secretsmanager_secret.api_key[0].name == "datadog_forwarder_api_key"
    error_message = "The Datadog API key was not set"
  }

  assert {
    condition     = resource.aws_cloudformation_stack.datadog_forwarder[0].name == "datadog-forwarder"
    error_message = "The log forwarder stack was not created"
  }

}

run "enabled_resource_collection" {
  variables {
    extended_resource_collection_enabled = true
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = local.datadog_resource_collection_enabled == true
    error_message = "The resource collection was not enabled"
  }

  assert {
    condition     = resource.datadog_integration_aws.default.extended_resource_collection_enabled == "true"
    error_message = "The extended resource collection was not enabled"
  }

  assert {
    condition     = resource.datadog_integration_aws.default.cspm_resource_collection_enabled == "false"
    error_message = "The CSPM resource collection was enabled"
  }
}

run "enabled_cspm" {
  variables {
    cspm_resource_collection_enabled = true
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = local.datadog_resource_collection_enabled == true
    error_message = "The resource collection was not enabled"
  }

  assert {
    condition     = resource.datadog_integration_aws.default.extended_resource_collection_enabled == "true"
    error_message = "The extended resource collection was not enabled"
  }

  assert {
    condition     = resource.datadog_integration_aws.default.cspm_resource_collection_enabled == "true"
    error_message = "The CSPM resource collection was enabled"
  }
}
