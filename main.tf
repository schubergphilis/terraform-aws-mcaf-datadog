locals {
  datadog_integration_role_name = "DatadogAWSIntegrationRole"
  datadog_aws_account_id        = "464622532012"
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
  providers     = { aws = aws }
  source        = "github.com/schubergphilis/terraform-aws-mcaf-role?ref=v0.3.0"
  name          = local.datadog_integration_role_name
  postfix       = false
  assume_policy = data.aws_iam_policy_document.datadog_integration_assume_role.json
  role_policy   = data.aws_iam_policy_document.datadog_integration_policy.json
  tags          = var.tags
}
