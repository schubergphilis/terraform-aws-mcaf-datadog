locals {
  datadog_aws_account_id        = "464622532012"
  datadog_forwarder_yaml        = data.http.datadog_forwarder_yaml_url.response_body
  datadog_integration_role_name = "DatadogAWSIntegrationRole"

  install_log_forwarder = var.api_key != null && var.install_log_forwarder ? 1 : 0

  enabled_namespaces = length(var.namespace_rules) == 0 ? null : {
    for index, namespace in toset(data.datadog_integration_aws_namespace_rules.rules.namespace_rules) :
    namespace => contains(var.namespace_rules, namespace)
  }
}

data "aws_caller_identity" "current" {}

data "http" "datadog_forwarder_yaml_url" {
  url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/${var.log_forwarder_version}.yaml"
}

data "datadog_integration_aws_namespace_rules" "rules" {}

resource "datadog_integration_aws" "default" {
  account_id                           = data.aws_caller_identity.current.account_id
  account_specific_namespace_rules     = local.enabled_namespaces
  cspm_resource_collection_enabled     = var.cspm_resource_collection_enabled
  excluded_regions                     = var.excluded_regions
  extended_resource_collection_enabled = var.cspm_resource_collection_enabled ? true : var.extended_resource_collection_enabled
  host_tags                            = var.datadog_tags
  role_name                            = module.datadog_integration_role.name
}

resource "datadog_integration_aws_tag_filter" "default" {
  for_each = var.metric_tag_filters

  account_id     = datadog_integration_aws.default.account_id
  namespace      = each.key
  tag_filter_str = each.value
}

data "aws_iam_policy_document" "datadog_integration_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.datadog_aws_account_id}:root"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"

      values = [
        datadog_integration_aws.default.external_id
      ]
    }
  }
}

data "aws_iam_policy_document" "datadog_integration_policy" {
  #checkov:skip=CKV_AWS_111: Resource wildcard cannot be scoped because it's not known beforehand which exact resources datadog need to be able to scrape
  #checkov:skip=CKV_AWS_356: Policy cannot be more scoped down, this is the recommended policy by datadog
  #checkov:skip=CKV_AWS_109: Policy cannot be more scoped down, this is the recommended policy by datadog
  statement {
    actions = [
      "apigateway:GET",
      "autoscaling:Describe*",
      "budgets:ViewBudget",
      "cloudfront:GetDistributionConfig",
      "cloudfront:ListDistributions",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetTrailStatus",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "codedeploy:BatchGet*",
      "codedeploy:List*",
      "directconnect:Describe*",
      "dynamodb:Describe*",
      "dynamodb:List*",
      "ec2:Describe*",
      "ecs:Describe*",
      "ecs:List*",
      "elasticache:Describe*",
      "elasticache:List*",
      "elasticfilesystem:Describe*",
      "elasticloadbalancing:Describe*",
      "elasticmapreduce:Describe*",
      "elasticmapreduce:List*",
      "es:DescribeElasticsearchDomains",
      "es:ListDomainNames",
      "es:ListTags",
      "fsx:DescribeFileSystems",
      "fsx:ListTagsForResource",
      "health:DescribeAffectedEntities",
      "health:DescribeEventDetails",
      "health:DescribeEvents",
      "kinesis:Describe*",
      "kinesis:List*",
      "lambda:AddPermission",
      "lambda:GetPolicy",
      "lambda:List*",
      "lambda:RemovePermission",
      "logs:DeleteSubscriptionFilter",
      "logs:Describe*",
      "logs:DescribeSubscriptionFilters",
      "logs:FilterLogEvents",
      "logs:Get*",
      "logs:PutSubscriptionFilter",
      "logs:TestMetricFilter",
      "rds:Describe*",
      "rds:List*",
      "redshift:DescribeClusters",
      "redshift:DescribeLoggingStatus",
      "route53:List*",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketNotification",
      "s3:GetBucketTagging",
      "s3:ListAllMyBuckets",
      "s3:PutBucketNotification",
      "ses:Get*",
      "sns:List*",
      "sns:Publish",
      "sqs:ListQueues",
      "states:DescribeStateMachine",
      "states:ListStateMachines",
      "support:*",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues",
      "xray:BatchGetTraces",
      "xray:GetTraceSummaries",
    ]
    resources = ["*"]
  }
}

module "datadog_integration_role" {
  source  = "schubergphilis/mcaf-role/aws"
  version = "~> 0.4.0"

  name          = local.datadog_integration_role_name
  assume_policy = data.aws_iam_policy_document.datadog_integration_assume_role.json
  create_policy = true
  policy_arns   = var.cspm_resource_collection_enabled ? ["arn:aws:iam::aws:policy/SecurityAudit"] : []
  postfix       = false
  role_policy   = data.aws_iam_policy_document.datadog_integration_policy.json
  tags          = var.tags
}

resource "aws_secretsmanager_secret" "api_key" {
  #checkov:skip=CKV_AWS_149: The cloudformation template provided by datadog does not support KMS CMK
  #checkov:skip=CKV2_AWS_57: Autorotate is not possible for this secret
  count       = local.install_log_forwarder
  name        = replace("${var.log_forwarder_name}_api_key", "-", "_")
  description = "Datadog API key used by ${var.log_forwarder_name} lambda"
}

resource "aws_secretsmanager_secret_version" "api_key" {
  count         = local.install_log_forwarder
  secret_id     = aws_secretsmanager_secret.api_key[0].id
  secret_string = var.api_key
}

resource "aws_cloudformation_stack" "datadog_forwarder" {
  #checkov:skip=CKV_AWS_124: Not preferred since this resource is managed via Terraform
  count             = local.install_log_forwarder
  name              = var.log_forwarder_name
  capabilities      = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  notification_arns = var.log_forwarder_cloudformation_sns_topic
  on_failure        = "ROLLBACK"
  template_body     = local.datadog_forwarder_yaml
  tags              = var.tags

  parameters = {
    DdApiKey            = "this_value_is_not_used"
    DdApiKeySecretArn   = aws_secretsmanager_secret.api_key[0].arn #checkov:skip=CKV_SECRET_6: this is the only way to pass this value
    DdSite              = var.site_url
    DdTags              = join(",", var.datadog_tags)
    FunctionName        = var.log_forwarder_name
    ReservedConcurrency = var.log_forwarder_reserved_concurrency
  }

  // The DdApiKey parameter has the NoEcho tag set in the cfn template, causing
  // Terraform to reset the value, so we ignore it.
  lifecycle {
    ignore_changes = [
      parameters["DdApiKey"]
    ]
  }

  depends_on = [datadog_integration_aws.default]
}

resource "datadog_integration_aws_lambda_arn" "default" {
  count      = local.install_log_forwarder
  account_id = data.aws_caller_identity.current.account_id
  lambda_arn = aws_cloudformation_stack.datadog_forwarder[0].outputs["DatadogForwarderArn"]
}

resource "datadog_integration_aws_log_collection" "default" {
  count      = var.log_collection_services != null ? 1 : 0
  account_id = data.aws_caller_identity.current.account_id
  services   = var.log_collection_services

  depends_on = [aws_cloudformation_stack.datadog_forwarder]
}
