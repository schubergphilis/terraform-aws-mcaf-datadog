locals {
  datadog_aws_account_id                  = "464622532012"
  datadog_forwarder_yaml                  = data.http.datadog_forwarder_yaml_url.response_body
  datadog_integration_role_name           = "DatadogAWSIntegrationRole"
  datadog_resource_collection_policy_name = "DatadogResourceCollectionPolicy"
  datadog_resource_collection_enabled     = var.cspm_resource_collection_enabled || var.extended_resource_collection_enabled ? true : false

  enabled_namespaces = length(var.namespace_rules) == 0 ? null : [
    for namespace in toset(data.datadog_integration_aws_namespace_rules.rules.namespace_rules) :
    namespace if !contains(var.namespace_rules, namespace)
  ]
}

data "aws_caller_identity" "current" {}

data "http" "datadog_forwarder_yaml_url" {
  url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/${var.log_forwarder_version}.yaml"
}

data "datadog_integration_aws_namespace_rules" "rules" {}

resource "datadog_integration_aws_external_id" "default" {}

resource "datadog_integration_aws_account" "default" {
  account_tags   = var.datadog_tags
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_partition  = "aws"
  aws_regions {
    include_all  = length(var.included_regions) == 0 ? true : null
    include_only = length(var.included_regions) > 0 ? var.included_regions : null
  }

  auth_config {
    aws_auth_config_role {
      role_name   = local.datadog_integration_role_name
      external_id = datadog_integration_aws_external_id.default.id
    }
  }

  logs_config {
    lambda_forwarder {
      lambdas = var.install_log_forwarder ? [aws_cloudformation_stack.datadog_forwarder[0].outputs["DatadogForwarderArn"]] : []
      sources = var.log_collection_services != null ? var.log_collection_services : []
    }
  }

  metrics_config {
    automute_enabled          = var.automute_enabled
    collect_cloudwatch_alarms = var.collect_cloudwatch_alarms
    collect_custom_metrics    = var.collect_custom_metrics
    namespace_filters {
      exclude_only = local.enabled_namespaces
    }
    dynamic "tag_filters" {
      for_each = var.metric_tag_filters
      content {
        namespace = tag_filters.key
        tags      = tag_filters.value
      }
    }
  }

  resources_config {
    cloud_security_posture_management_collection = var.cspm_resource_collection_enabled
    extended_collection                          = local.datadog_resource_collection_enabled
  }

  traces_config {
    xray_services {
      include_all  = length(var.xray_services) == 2 ? true : null
      include_only = length(var.xray_services) < 2 ? var.xray_services : null
    }
  }

  depends_on = [datadog_integration_aws_external_id.default]
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
        datadog_integration_aws_external_id.default.id
      ]
    }
  }
}

data "aws_iam_policy_document" "datadog_integration_policy" {
  #https://docs.datadoghq.com/integrations/amazon_web_services/#aws-integration-iam-policy
  #checkov:skip=CKV_AWS_111: Resource wildcard cannot be scoped because it's not known beforehand which exact resources datadog need to be able to scrape
  #checkov:skip=CKV_AWS_356: Policy cannot be more scoped down, this is the recommended policy by datadog
  #checkov:skip=CKV_AWS_109: Policy cannot be more scoped down, this is the recommended policy by datadog
  statement {
    actions = [
      "account:GetAccountInformation",
      "airflow:GetEnvironment",
      "airflow:ListEnvironments",
      "apigateway:GET",
      "appsync:ListGraphqlApis",
      "autoscaling:Describe*",
      "backup:List*",
      "batch:DescribeJobDefinitions",
      "batch:DescribeJobQueues",
      "batch:DescribeJobs",
      "batch:ListJobs",
      "bcm-data-exports:GetExport",
      "bcm-data-exports:ListExports",
      "budgets:ViewBudget",
      "cloudfront:GetDistributionConfig",
      "cloudfront:ListDistributions",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetTrail",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:ListTrails",
      "cloudtrail:LookupEvents",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "codebuild:BatchGetProjects",
      "codebuild:ListProjects",
      "codedeploy:BatchGet*",
      "codedeploy:List*",
      "cur:DescribeReportDefinitions",
      "directconnect:Describe*",
      "dms:DescribeReplicationInstances",
      "dynamodb:Describe*",
      "dynamodb:List*",
      "ec2:Describe*",
      "ecs:Describe*",
      "ecs:List*",
      "eks:DescribeCluster",
      "eks:ListClusters",
      "elasticache:Describe*",
      "elasticache:List*",
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeTags",
      "elasticloadbalancing:Describe*",
      "elasticmapreduce:Describe*",
      "elasticmapreduce:List*",
      "es:DescribeElasticsearchDomains",
      "es:ListDomainNames",
      "es:ListTags",
      "events:CreateEventBus",
      "fsx:DescribeFileSystems",
      "fsx:ListTagsForResource",
      "glue:BatchGetJobs",
      "glue:GetJob",
      "glue:GetJobs",
      "glue:ListJobs",
      "health:DescribeAffectedEntities",
      "health:DescribeEventDetails",
      "health:DescribeEvents",
      "iam:ListAccountAliases",
      "iot:GetV2LoggingOptions",
      "kinesis:Describe*",
      "kinesis:List*",
      "lambda:List*",
      "logs:DeleteSubscriptionFilter",
      "logs:DescribeDeliveries",
      "logs:DescribeDeliverySources",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DescribeSubscriptionFilters",
      "logs:FilterLogEvents",
      "logs:GetDeliveryDestination",
      "logs:PutSubscriptionFilter",
      "logs:TestMetricFilter",
      "network-firewall:DescribeLoggingConfiguration",
      "network-firewall:ListFirewalls",
      "oam:ListAttachedLinks",
      "oam:ListSinks",
      "organizations:Describe*",
      "organizations:List*",
      "rds:Describe*",
      "rds:List*",
      "redshift-serverless:ListNamespaces",
      "redshift:DescribeClusters",
      "redshift:DescribeLoggingStatus",
      "route53:List*",
      "route53resolver:ListResolverQueryLogConfigs",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketNotification",
      "s3:GetBucketTagging",
      "s3:GetObject",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:PutBucketNotification",
      "ses:Get*",
      "ses:List*",
      "sns:GetSubscriptionAttributes",
      "sns:List*",
      "sns:Publish",
      "sqs:ListQueues",
      "ssm:GetServiceSetting",
      "ssm:ListCommands",
      "states:DescribeStateMachine",
      "states:ListStateMachines",
      "support:DescribeTrustedAdvisor*",
      "support:RefreshTrustedAdvisorCheck",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues",
      "timestream:DescribeEndpoints",
      "trustedadvisor:ListRecommendationResources",
      "trustedadvisor:ListRecommendations",
      "wafv2:ListLoggingConfigurations",
      "xray:BatchGetTraces",
      "xray:GetTraceSummaries"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "datadog_resource_collection_policy" {
  #https://docs.datadoghq.com/integrations/amazon_web_services/#aws-resource-collection-iam-policy
  #checkov:skip=CKV_AWS_111: Resource wildcard cannot be scoped because it's not known beforehand which exact resources datadog need to be able to scrape
  #checkov:skip=CKV_AWS_356: Policy cannot be more scoped down, this is the recommended policy by datadog
  statement {
    actions = [
      "amplify:ListApps",
      "amplify:ListArtifacts",
      "amplify:ListBackendEnvironments",
      "amplify:ListBranches",
      "amplify:ListDomainAssociations",
      "amplify:ListJobs",
      "amplify:ListWebhooks",
      "appstream:DescribeAppBlockBuilders",
      "appstream:DescribeAppBlocks",
      "appstream:DescribeApplications",
      "appstream:DescribeFleets",
      "appstream:DescribeImageBuilders",
      "appstream:DescribeImages",
      "appstream:DescribeStacks",
      "batch:DescribeJobQueues",
      "batch:DescribeSchedulingPolicies",
      "batch:ListSchedulingPolicies",
      "deadline:GetBudget",
      "deadline:GetLicenseEndpoint",
      "deadline:GetQueue",
      "deadline:ListBudgets",
      "deadline:ListFarms",
      "deadline:ListFleets",
      "deadline:ListLicenseEndpoints",
      "deadline:ListMonitors",
      "deadline:ListQueues",
      "deadline:ListWorkers",
      "identitystore:DescribeGroup",
      "identitystore:DescribeGroupMembership",
      "imagebuilder:GetContainerRecipe",
      "imagebuilder:GetDistributionConfiguration",
      "imagebuilder:GetImageRecipe",
      "imagebuilder:GetInfrastructureConfiguration",
      "imagebuilder:GetLifecyclePolicy",
      "imagebuilder:GetWorkflow",
      "imagebuilder:ListComponents",
      "imagebuilder:ListContainerRecipes",
      "imagebuilder:ListDistributionConfigurations",
      "imagebuilder:ListImagePipelines",
      "imagebuilder:ListImageRecipes",
      "imagebuilder:ListImages",
      "imagebuilder:ListInfrastructureConfigurations",
      "imagebuilder:ListLifecyclePolicies",
      "imagebuilder:ListWorkflows",
      "mobiletargeting:GetApps",
      "mobiletargeting:GetCampaigns",
      "mobiletargeting:GetChannels",
      "mobiletargeting:GetEventStream",
      "mobiletargeting:GetRecommenderConfigurations",
      "mobiletargeting:GetSegments",
      "mobiletargeting:ListJourneys",
      "mobiletargeting:ListTemplates",
      "sms-voice:DescribeConfigurationSets",
      "sms-voice:DescribeOptOutLists",
      "sms-voice:DescribePhoneNumbers",
      "sms-voice:DescribePools",
      "sms-voice:DescribeProtectConfigurations",
      "sms-voice:DescribeRegistrationAttachments",
      "sms-voice:DescribeRegistrations",
      "sms-voice:DescribeSenderIds",
      "sms-voice:DescribeVerifiedDestinationNumbers",
      "social-messaging:ListLinkedWhatsAppBusinessAccounts"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "datadog_resource_collection_policy" {
  count = local.datadog_resource_collection_enabled ? 1 : 0

  name        = local.datadog_resource_collection_policy_name
  description = "Datadog policy to collect additional attributes and configuration information about the resources in your AWS account"
  policy      = data.aws_iam_policy_document.datadog_resource_collection_policy.json
}

module "datadog_integration_role" {
  source  = "schubergphilis/mcaf-role/aws"
  version = "~> 0.5.3"

  name          = local.datadog_integration_role_name
  assume_policy = data.aws_iam_policy_document.datadog_integration_assume_role.json
  create_policy = true
  policy_arns   = local.datadog_resource_collection_enabled ? ["arn:aws:iam::aws:policy/SecurityAudit", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.datadog_resource_collection_policy_name}"] : []
  postfix       = false
  role_policy   = data.aws_iam_policy_document.datadog_integration_policy.json
  tags          = var.tags

  depends_on = [aws_iam_policy.datadog_resource_collection_policy]
}

resource "datadog_api_key" "default" {
  count = var.create_api_key ? 1 : 0

  name = var.api_key_name
}

resource "aws_secretsmanager_secret" "api_key" {
  #checkov:skip=CKV_AWS_149: The cloudformation template provided by datadog does not support KMS CMK
  #checkov:skip=CKV2_AWS_57: Autorotate is not possible for this secret
  count = var.install_log_forwarder ? 1 : 0

  name        = replace("${var.log_forwarder_name}_api_key", "-", "_")
  description = "Datadog API key used by ${var.log_forwarder_name} lambda"
}

resource "aws_secretsmanager_secret_version" "api_key" {
  count         = var.install_log_forwarder ? 1 : 0
  secret_id     = aws_secretsmanager_secret.api_key[0].id
  secret_string = var.create_api_key ? datadog_api_key.default[0].key : var.api_key
}

resource "aws_cloudformation_stack" "datadog_forwarder" {
  #checkov:skip=CKV_AWS_124: Not preferred since this resource is managed via Terraform
  count = var.install_log_forwarder ? 1 : 0

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
}
