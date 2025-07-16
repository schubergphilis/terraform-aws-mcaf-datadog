# Migration Guide: v0.x to v1.0.0

This guide helps you migrate from v0.x (using deprecated Datadog resources) to v1.0.0 (using new Datadog AWS account integration resources).

## Overview

Version 1.0.0 migrates from deprecated `datadog_integration_aws*` resources to the new `datadog_integration_aws_account*` resources introduced in Datadog provider v4.0.0.

**Key benefit**: This migration uses Terraform's `moved` blocks for **zero-downtime migration**. Resources are renamed in state only, not destroyed and recreated.

## Prerequisites

- Terraform >= 1.9.0 (already required by v0.x)
- Access to modify your Terraform state
- Ability to upgrade the Datadog provider in your root module

## Migration Steps

### 1. Update Module Version

In your Terraform code where you reference this module:

```hcl
module "datadog" {
  source  = "schubergphilis/mcaf-datadog/aws"
  version = "~> 1.0"

  # ... your existing configuration ...
}
```

### 2. Update Datadog Provider Version

In your root module's `terraform.tf` or `versions.tf`:

```hcl
terraform {
  required_providers {
    datadog = {
      source  = "datadog/datadog"
      version = ">= 3.84.0"  # Update from >= 3.39
    }
  }
}
```

### 3. Run Terraform Init

```bash
terraform init -upgrade
```

This will download the new module version and upgrade the Datadog provider.

### 4. Run Terraform Plan

```bash
terraform plan
```

**Expected output**: You should see messages indicating resources are being moved:

```
# datadog_integration_aws.default has moved to datadog_integration_aws_account.default
  ~ resource "datadog_integration_aws_account" "default" {
        # (no changes - resource is being moved)
    }

# datadog_integration_aws_tag_filter.default has moved to datadog_integration_aws_account_tag_filter.default
  ~ resource "datadog_integration_aws_account_tag_filter" "default" {
        # (no changes - resource is being moved)
    }

# ... similar for lambda_arn and log_collection resources ...
```

**Important**: If you see resources being destroyed and recreated (shown with `-/+` or `destroy` and `create` actions), **STOP** and review the plan carefully. The migration should only show moves, not recreations.

### 5. Apply Changes

```bash
terraform apply
```

Terraform will update your state file to reference the new resource types. The actual Datadog integration resources remain unchanged.

## What Changed

### Resource Type Mappings

| Old Resource Type | New Resource Type |
|-------------------|-------------------|
| `datadog_integration_aws` | `datadog_integration_aws_account` |
| `datadog_integration_aws_tag_filter` | `datadog_integration_aws_account_tag_filter` |
| `datadog_integration_aws_lambda_arn` | `datadog_integration_aws_account_lambda_arn` |
| `datadog_integration_aws_log_collection` | `datadog_integration_aws_account_log_collection` |

### Configuration Changes

**Configuration that requires changes**
- `excluded regions` has been reversed into `included regions`. Default is to include all.

**No configuration changes required**. All input variables remain the same:
- `cspm_resource_collection_enabled`
- `extended_resource_collection_enabled`
- `install_log_forwarder`
- `log_collection_services`
- `metric_tag_filters`
- All other variables remain unchanged

## Troubleshooting

### Issue: Plan shows resources being recreated

**Symptom**: `terraform plan` shows resources with `-/+` (destroy and create) instead of move operations.

**Solution**:
1. Ensure you've upgraded the Datadog provider to >= 3.84.0
2. Verify you're using module version >= 1.0.0
3. Run `terraform init -upgrade` again

### Issue: Provider version conflict

**Symptom**: Error about incompatible provider versions.

**Solution**: Update your root module's provider version constraints to allow Datadog provider >= 3.84.0.

### Issue: Moved blocks not recognized

**Symptom**: Terraform doesn't recognize the `moved` blocks.

**Solution**: Ensure Terraform version is >= 1.9.0 (required by this module). Run `terraform version` to check.

## Rollback Plan

If you need to rollback to v0.x:

1. **Before applying**: Simply revert your module version back to `~> 0.9` and run `terraform init -upgrade`

2. **After applying**: The state has been migrated. To rollback:
   ```bash
   # Downgrade module version in your code
   terraform init -upgrade

   # Manually rename resources in state (if needed)
   terraform state mv 'datadog_integration_aws_account.default' 'datadog_integration_aws.default'
   terraform state mv 'datadog_integration_aws_account_tag_filter.default' 'datadog_integration_aws_tag_filter.default'
   # ... repeat for lambda_arn and log_collection ...
   ```

## Verification

After migration, verify the integration is working:

1. Check Datadog UI: AWS integration should show as connected
2. Verify metrics are flowing: Check for AWS metrics in Datadog
3. If using log forwarder: Verify logs are being received

## Support

If you encounter issues not covered in this guide:
- Check the [CHANGELOG](CHANGELOG.md) for detailed changes
- Review [GitHub Issues](https://github.com/schubergphilis/terraform-aws-mcaf-datadog/issues)
- Open a new issue with details about your problem

## Timeline

The deprecated resources will eventually be removed from the Datadog provider. Migrating to v1.0.0 ensures your infrastructure remains compatible with future Datadog provider releases.
