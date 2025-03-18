# terraform-aws-mcaf-datadog

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.39 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | >= 3.39 |
| <a name="provider_http"></a> [http](#provider\_http) | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_datadog_integration_role"></a> [datadog\_integration\_role](#module\_datadog\_integration\_role) | schubergphilis/mcaf-role/aws | ~> 0.4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack.datadog_forwarder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |
| [aws_iam_policy.datadog_resource_collection_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_secretsmanager_secret.api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [datadog_api_key.default](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/api_key) | resource |
| [datadog_integration_aws.default](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_aws) | resource |
| [datadog_integration_aws_lambda_arn.default](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_aws_lambda_arn) | resource |
| [datadog_integration_aws_log_collection.default](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_aws_log_collection) | resource |
| [datadog_integration_aws_tag_filter.default](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_aws_tag_filter) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.datadog_integration_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.datadog_integration_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.datadog_resource_collection_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [datadog_integration_aws_namespace_rules.rules](https://registry.terraform.io/providers/datadog/datadog/latest/docs/data-sources/integration_aws_namespace_rules) | data source |
| [http_http.datadog_forwarder_yaml_url](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | Datadog API key | `string` | `null` | no |
| <a name="input_api_key_name"></a> [api\_key\_name](#input\_api\_key\_name) | Name of the Datadog API key used if create\_api\_key is set to true, otherwise ignored | `string` | `null` | no |
| <a name="input_create_api_key"></a> [create\_api\_key](#input\_create\_api\_key) | Set to true to create a Datadog API key. Warning: by default Datadog allows maximum 50 API keys per organization. | `bool` | `false` | no |
| <a name="input_cspm_resource_collection_enabled"></a> [cspm\_resource\_collection\_enabled](#input\_cspm\_resource\_collection\_enabled) | Whether Datadog collects cloud security posture management resources from your AWS account. | `bool` | `false` | no |
| <a name="input_datadog_tags"></a> [datadog\_tags](#input\_datadog\_tags) | Array of tags (in the form key:value) to add to all hosts and metrics | `list(string)` | `[]` | no |
| <a name="input_excluded_regions"></a> [excluded\_regions](#input\_excluded\_regions) | List of regions to be excluded from metrics collection in Datadog integration | `list(string)` | `[]` | no |
| <a name="input_extended_resource_collection_enabled"></a> [extended\_resource\_collection\_enabled](#input\_extended\_resource\_collection\_enabled) | Whether Datadog collects additional attributes and configuration information about the resources in your AWS account | `bool` | `false` | no |
| <a name="input_install_log_forwarder"></a> [install\_log\_forwarder](#input\_install\_log\_forwarder) | Set to true to install the Datadog Log Forwarder (requires var.api\_key to be set) | `bool` | `false` | no |
| <a name="input_log_collection_services"></a> [log\_collection\_services](#input\_log\_collection\_services) | A list of services to collect logs from. Valid values are s3/elb/elbv2/cloudfront/redshift/lambda. | `list(string)` | `null` | no |
| <a name="input_log_forwarder_cloudformation_sns_topic"></a> [log\_forwarder\_cloudformation\_sns\_topic](#input\_log\_forwarder\_cloudformation\_sns\_topic) | SNS topic ARN to receive stack events from the datadog forwarder cloudformation stack | `list(string)` | `null` | no |
| <a name="input_log_forwarder_name"></a> [log\_forwarder\_name](#input\_log\_forwarder\_name) | AWS log forwarder lambda name | `string` | `"datadog-forwarder"` | no |
| <a name="input_log_forwarder_reserved_concurrency"></a> [log\_forwarder\_reserved\_concurrency](#input\_log\_forwarder\_reserved\_concurrency) | AWS log forwarder reserved concurrency | `number` | `null` | no |
| <a name="input_log_forwarder_version"></a> [log\_forwarder\_version](#input\_log\_forwarder\_version) | AWS log forwarder version to install | `string` | `"latest"` | no |
| <a name="input_metric_tag_filters"></a> [metric\_tag\_filters](#input\_metric\_tag\_filters) | A list of namespaces and a tag filter query to filter metric collection of resources | `map(string)` | `{}` | no |
| <a name="input_namespace_rules"></a> [namespace\_rules](#input\_namespace\_rules) | Explicit list of namespaces to enable for metrics collection. If not specific, default namespaces are enabled | `list(string)` | `[]` | no |
| <a name="input_site_url"></a> [site\_url](#input\_site\_url) | Define your Datadog Site to send data to. For the Datadog US site, set to datadoghq.com | `string` | `"datadoghq.eu"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the bucket | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_key"></a> [api\_key](#output\_api\_key) | Datadog API key if created by the module |
| <a name="output_forwarder_arn"></a> [forwarder\_arn](#output\_forwarder\_arn) | Datadog log forwarder lambda ARN |
<!-- END_TF_DOCS -->
