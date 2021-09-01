locals {
  datadog_integration_role_name = "DatadogAWSIntegrationRole"
  datadog_aws_account_id        = "464622532012"

  install_log_forwarder = var.api_key != null && var.install_log_forwarder ? 1 : 0
}

data "aws_caller_identity" "current" {}

resource "datadog_integration_aws" "default" {
  account_id = data.aws_caller_identity.current.account_id
  role_name  = local.datadog_integration_role_name
  host_tags  = var.datadog_tags
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
  source        = "github.com/schubergphilis/terraform-aws-mcaf-role?ref=v0.3.0"
  name          = local.datadog_integration_role_name
  postfix       = false
  assume_policy = data.aws_iam_policy_document.datadog_integration_assume_role.json
  role_policy   = data.aws_iam_policy_document.datadog_integration_policy.json
  tags          = var.tags
}

resource "aws_secretsmanager_secret" "api_key" {
  count       = local.install_log_forwarder
  name        = replace("${var.log_forwarder_name}_api_key", "-", "_")
  description = "Datadog API key used by ${var.log_forwarder_name} lambda"
}

resource "aws_secretsmanager_secret_version" "api_key" {
  count         = local.install_log_forwarder
  secret_id     = aws_secretsmanager_secret.api_key.0.id
  secret_string = var.api_key
}

resource "aws_cloudformation_stack" "datadog_forwarder" {
  count        = local.install_log_forwarder
  name         = var.log_forwarder_name
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  on_failure   = "ROLLBACK"
  template_url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/${var.log_forwarder_version}.yaml"
  tags         = var.tags

  parameters = {
    DdApiKey          = "this_value_is_not_used"
    DdApiKeySecretArn = aws_secretsmanager_secret.api_key.0.arn
    DdSite            = var.site_url
    DdTags            = join(",", var.datadog_tags)
    FunctionName      = var.log_forwarder_name
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
  lambda_arn = aws_cloudformation_stack.datadog_forwarder.0.outputs["DatadogForwarderArn"]
}

resource "datadog_integration_aws_log_collection" "default" {
  count      = var.log_collection_services != null ? 1 : 0
  account_id = data.aws_caller_identity.current.account_id
  services   = var.log_collection_services
}
