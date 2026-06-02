# Upgrading Notes

This document captures required refactoring on your part when upgrading to a module version that contains breaking changes.

## Upgrading to v1.0.0

### Key Changes

Version 1.0.0 migrates from deprecated `datadog_integration_aws*` resources to the new `datadog_integration_aws_account` resource introduced in Datadog provider v3.50.0.

_Note: While the module supports Datadog provider 4.x, you first need to migrate to the new resources using provider version 3.x. After the first run, you can update. This prevents `no schema found` errors related to the deprecated resources that were removed in version 4.x._

#### Variables

The following variables have been added:

- `automute_enabled`: defaults to `true`
- `collect_cloudwatch_alarms`: defaults to `false`
- `collect_custom_metrics`: defaults to `false`
- `included_regions`: defaults to `[]`, resulting in all regions being included
- `xray_services`: defaults to `[]`, resulting in all X-Ray services being included

The following variables have been **removed**:

- `excluded_regions`: use the inverse `included_regions` instead

### Migration Guide

If you previously used `excluded_regions`, replace it with the inverse `included_regions`. In most cases this will result in a simpler setup.

There are two options for migrating existing integrations to version 1.x:

1. By default, the module will remove the existing integration and recreate it using the new resource.
   **Warning:** The full impact of this is not entirely clear. While no data loss has been observed, there may be a temporary loss of ingestion during the transition, so keep that in mind.

2. Import the existing integration and remove the old resources from state without destroying them. This follows the recommended migration path from Datadog and is generally safer, though more involved. Instructions for this option are below.

#### Importing the existing integration

Importing the existing integration requires an AWS Account Config ID from Datadog. This ID is not exposed by any resource or data source in Terraform, so it must be retrieved independently using the Datadog API method [List all AWS integrations](https://docs.datadoghq.com/api/latest/aws-integration/#list-all-aws-integrations).

In the output of that API, the `id` attribute of the integration object is the ID needed for the import.

The integration can then be imported using an `import` block like this:

```
import {
  to = module.datadog.datadog_integration_aws_account.default
  id = "<ID_FROM_THE_API>"
}
```

As part of the module upgrade, we've provided a script to make this transition easier. See the section below for more information.

#### Script to retrieve configuration IDs

The `scripts` directory contains a shell script, `import_config_ids.sh`, that retrieves all config IDs from the Datadog API and generates a local block that can be used to import the integration dynamically. This is especially useful when using prefix-based workspaces to set account baselines.

Prerequisites for the script are:

- `curl` and `jq` installed and available
- a Datadog API Key
- a Datadog Application Key with the `aws_configuration_read` permission. No other permissions are required, so the key can be scoped to this permission only.

Usage instructions are available in the script header. The script will output an HCL block in the following format:

```
locals {
  dd_aws_integration_ids = {
    "012345678901" = "SOME_UUID"
    "123456789012" = "SOME_OTHER_UUID"
  }
}
```

You can then create an import block like this to import the resource using the retrieved ID:

```
import {
  to = module.datadog.datadog_integration_aws_account.default
  id = local.dd_aws_integration_ids[data.aws_caller_identity.current.account_id]
}
```

_Note: the example above uses the `aws_caller_identity` data source to retrieve the AWS Account ID._

#### Remove deprecated resources

The deprecated resources can be removed from state using `removed` blocks like this:

```
removed {
  from = module.datadog.datadog_integration_aws.default
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.datadog.datadog_integration_aws_lambda_arn.default
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.datadog.datadog_integration_aws_log_collection.default
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.datadog.datadog_integration_aws_tag_filter.default
  lifecycle {
    destroy = false
  }
}

```
