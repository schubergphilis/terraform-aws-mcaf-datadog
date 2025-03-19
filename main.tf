locals {
  datadog_aws_account_id                  = "464622532012"
  datadog_forwarder_yaml                  = data.http.datadog_forwarder_yaml_url.response_body
  datadog_integration_role_name           = "DatadogAWSIntegrationRole"
  datadog_resource_collection_policy_name = "DatadogResourceCollectionPolicy"
  datadog_resource_collection_enabled     = var.cspm_resource_collection_enabled || var.extended_resource_collection_enabled ? true : false

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
  extended_resource_collection_enabled = local.datadog_resource_collection_enabled
  host_tags                            = var.datadog_tags
  role_name                            = local.datadog_integration_role_name
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
  #https://docs.datadoghq.com/integrations/amazon_web_services/#aws-integration-iam-policy
  #checkov:skip=CKV_AWS_111: Resource wildcard cannot be scoped because it's not known beforehand which exact resources datadog need to be able to scrape
  #checkov:skip=CKV_AWS_356: Policy cannot be more scoped down, this is the recommended policy by datadog
  #checkov:skip=CKV_AWS_109: Policy cannot be more scoped down, this is the recommended policy by datadog
  statement {
    actions = [
      "apigateway:GET",
      "aoss:BatchGetCollection",
      "aoss:ListCollections",
      "autoscaling:Describe*",
      "backup:List*",
      "bcm-data-exports:GetExport",
      "bcm-data-exports:ListExports",
      "bedrock:GetAgent",
      "bedrock:GetAgentAlias",
      "bedrock:GetFlow",
      "bedrock:GetFlowAlias",
      "bedrock:GetGuardrail",
      "bedrock:GetImportedModel",
      "bedrock:GetInferenceProfile",
      "bedrock:GetMarketplaceModelEndpoint",
      "bedrock:ListAgentAliases",
      "bedrock:ListAgents",
      "bedrock:ListFlowAliases",
      "bedrock:ListFlows",
      "bedrock:ListGuardrails",
      "bedrock:ListImportedModels",
      "bedrock:ListInferenceProfiles",
      "bedrock:ListMarketplaceModelEndpoints",
      "bedrock:ListPromptRouters",
      "bedrock:ListProvisionedModelThroughputs",
      "budgets:ViewBudget",
      "cassandra:Select",
      "cloudfront:GetDistributionConfig",
      "cloudfront:ListDistributions",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:LookupEvents",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "codeartifact:DescribeDomain",
      "codeartifact:DescribePackageGroup",
      "codeartifact:DescribeRepository",
      "codeartifact:ListDomains",
      "codeartifact:ListPackageGroups",
      "codeartifact:ListPackages",
      "codedeploy:BatchGet*",
      "codedeploy:List*",
      "codepipeline:ListWebhooks",
      "cur:DescribeReportDefinitions",
      "directconnect:Describe*",
      "dynamodb:Describe*",
      "dynamodb:List*",
      "ec2:Describe*",
      "ec2:GetAllowedImagesSettings",
      "ec2:GetEbsDefaultKmsKeyId",
      "ec2:GetInstanceMetadataDefaults",
      "ec2:GetSerialConsoleAccessStatus",
      "ec2:GetSnapshotBlockPublicAccessState",
      "ec2:GetTransitGatewayPrefixListReferences",
      "ec2:SearchTransitGatewayRoutes",
      "ecs:Describe*",
      "ecs:List*",
      "elasticache:Describe*",
      "elasticache:List*",
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeTags",
      "elasticloadbalancing:Describe*",
      "elasticmapreduce:Describe*",
      "elasticmapreduce:List*",
      "emr-containers:ListManagedEndpoints",
      "emr-containers:ListSecurityConfigurations",
      "emr-containers:ListVirtualClusters",
      "es:DescribeElasticsearchDomains",
      "es:ListDomainNames",
      "es:ListTags",
      "events:CreateEventBus",
      "fsx:DescribeFileSystems",
      "fsx:ListTagsForResource",
      "glacier:GetVaultNotifications",
      "glue:ListRegistries",
      "grafana:DescribeWorkspace",
      "greengrass:GetComponent",
      "greengrass:GetConnectivityInfo",
      "greengrass:GetCoreDevice",
      "greengrass:GetDeployment",
      "health:DescribeAffectedEntities",
      "health:DescribeEventDetails",
      "health:DescribeEvents",
      "kinesis:Describe*",
      "kinesis:List*",
      "lambda:GetPolicy",
      "lambda:List*",
      "lightsail:GetInstancePortStates",
      "logs:DeleteSubscriptionFilter",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DescribeSubscriptionFilters",
      "logs:FilterLogEvents",
      "logs:PutSubscriptionFilter",
      "logs:TestMetricFilter",
      "macie2:GetAllowList",
      "macie2:GetCustomDataIdentifier",
      "macie2:ListAllowLists",
      "macie2:ListCustomDataIdentifiers",
      "macie2:ListMembers",
      "macie2:GetMacieSession",
      "managedblockchain:GetAccessor",
      "managedblockchain:GetMember",
      "managedblockchain:GetNetwork",
      "managedblockchain:GetNode",
      "managedblockchain:GetProposal",
      "managedblockchain:ListAccessors",
      "managedblockchain:ListInvitations",
      "managedblockchain:ListMembers",
      "managedblockchain:ListNodes",
      "managedblockchain:ListProposals",
      "memorydb:DescribeAcls",
      "memorydb:DescribeMultiRegionClusters",
      "memorydb:DescribeParameterGroups",
      "memorydb:DescribeReservedNodes",
      "memorydb:DescribeSnapshots",
      "memorydb:DescribeSubnetGroups",
      "memorydb:DescribeUsers",
      "oam:ListAttachedLinks",
      "oam:ListSinks",
      "organizations:Describe*",
      "organizations:List*",
      "osis:GetPipeline",
      "osis:GetPipelineBlueprint",
      "osis:ListPipelineBlueprints",
      "osis:ListPipelines",
      "proton:GetComponent",
      "proton:GetDeployment",
      "proton:GetEnvironment",
      "proton:GetEnvironmentAccountConnection",
      "proton:GetEnvironmentTemplate",
      "proton:GetEnvironmentTemplateVersion",
      "proton:GetRepository",
      "proton:GetService",
      "proton:GetServiceInstance",
      "proton:GetServiceTemplate",
      "proton:GetServiceTemplateVersion",
      "proton:ListComponents",
      "proton:ListDeployments",
      "proton:ListEnvironmentAccountConnections",
      "proton:ListEnvironmentTemplateVersions",
      "proton:ListEnvironmentTemplates",
      "proton:ListEnvironments",
      "proton:ListRepositories",
      "proton:ListServiceInstances",
      "proton:ListServiceTemplateVersions",
      "proton:ListServiceTemplates",
      "proton:ListServices",
      "qldb:ListJournalKinesisStreamsForLedger",
      "rds:Describe*",
      "rds:List*",
      "redshift:DescribeClusters",
      "redshift:DescribeLoggingStatus",
      "redshift-serverless:ListEndpointAccess",
      "redshift-serverless:ListManagedWorkgroups",
      "redshift-serverless:ListNamespaces",
      "redshift-serverless:ListRecoveryPoints",
      "redshift-serverless:ListSnapshots",
      "route53:List*",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketNotification",
      "s3:GetBucketTagging",
      "s3:ListAccessGrants",
      "s3:ListAllMyBuckets",
      "s3:PutBucketNotification",
      "s3express:GetBucketPolicy",
      "s3express:GetEncryptionConfiguration",
      "s3express:ListAllMyDirectoryBuckets",
      "s3tables:GetTableBucketMaintenanceConfiguration",
      "s3tables:ListTableBuckets",
      "s3tables:ListTables",
      "savingsplans:DescribeSavingsPlanRates",
      "savingsplans:DescribeSavingsPlans",
      "secretsmanager:GetResourcePolicy",
      "ses:Get*",
      "ses:ListAddonInstances",
      "ses:ListAddonSubscriptions",
      "ses:ListAddressLists",
      "ses:ListArchives",
      "ses:ListContactLists",
      "ses:ListCustomVerificationEmailTemplates",
      "ses:ListMultiRegionEndpoints",
      "ses:ListIngressPoints",
      "ses:ListRelays",
      "ses:ListRuleSets",
      "ses:ListTemplates",
      "ses:ListTrafficPolicies",
      "sns:GetSubscriptionAttributes",
      "sns:List*",
      "sns:Publish",
      "sqs:ListQueues",
      "states:DescribeStateMachine",
      "states:ListStateMachines",
      "support:DescribeTrustedAdvisor*",
      "support:RefreshTrustedAdvisorCheck",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues",
      "timestream:DescribeEndpoints",
      "timestream:ListTables",
      "waf-regional:GetRule",
      "waf-regional:GetRuleGroup",
      "waf-regional:ListRuleGroups",
      "waf-regional:ListRules",
      "waf:GetRule",
      "waf:GetRuleGroup",
      "waf:ListRuleGroups",
      "waf:ListRules",
      "wafv2:GetIPSet",
      "wafv2:GetLoggingConfiguration",
      "wafv2:GetRegexPatternSet",
      "wafv2:GetRuleGroup",
      "wafv2:ListLoggingConfigurations",
      "workmail:DescribeOrganization",
      "workmail:ListOrganizations",
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
      "backup:ListRecoveryPointsByBackupVault",
      "cassandra:Select",
      "ec2:GetSnapshotBlockPublicAccessState",
      "glacier:GetVaultNotifications",
      "glue:ListRegistries",
      "lightsail:GetInstancePortStates",
      "savingsplans:DescribeSavingsPlanRates",
      "savingsplans:DescribeSavingsPlans",
      "timestream:DescribeEndpoints",
      "waf-regional:ListRuleGroups",
      "waf-regional:ListRules",
      "waf:ListRuleGroups",
      "waf:ListRules",
      "wafv2:GetIPSet",
      "wafv2:GetRegexPatternSet",
      "wafv2:GetRuleGroup",
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
  version = "~> 0.4.0"

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

  depends_on = [datadog_integration_aws.default]
}

resource "datadog_integration_aws_lambda_arn" "default" {
  count = var.install_log_forwarder ? 1 : 0

  account_id = data.aws_caller_identity.current.account_id
  lambda_arn = aws_cloudformation_stack.datadog_forwarder[0].outputs["DatadogForwarderArn"]
}

resource "datadog_integration_aws_log_collection" "default" {
  count = var.log_collection_services != null ? 1 : 0

  account_id = data.aws_caller_identity.current.account_id
  services   = var.log_collection_services

  depends_on = [aws_cloudformation_stack.datadog_forwarder]
}
