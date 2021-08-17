# terraform-aws-mcaf-datadog

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| datadog | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | A mapping of tags to assign to the bucket | `map(string)` | n/a | yes |
| api\_key | Datadog API key | `string` | `null` | no |
| datadog\_tags | Array of tags (in the form key:value) to add to all hosts and metrics | `list(string)` | `[]` | no |
| install\_log\_forwarder | Set to true to install the Datadog Log Forwarder (requires var.api\_key to be set) | `bool` | `false` | no |
| log\_collection\_services | A list of services to collect logs from. Valid values are s3/elb/elbv2/cloudfront/redshift/lambda. | `list(string)` | `null` | no |
| log\_forwarder\_name | AWS log forwarder lambda name | `string` | `"datadog-forwarder"` | no |
| log\_forwarder\_version | AWS log forwarder version to install | `string` | `"latest"` | no |
| site\_url | Define your Datadog Site to send data to. For the Datadog US site, set to datadoghq.com | `string` | `"datadoghq.eu"` | no |

## Outputs

| Name | Description |
|------|-------------|
| forwarder\_arn | Datadog log forwarder lambda ARN |

<!--- END_TF_DOCS --->
