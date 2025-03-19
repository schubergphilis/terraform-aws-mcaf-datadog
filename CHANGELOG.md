# Changelog

All notable changes to this project will automatically be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.9.0 - 2025-03-19

### What's Changed

#### 🚀 Features

* feature: option to create Datadog API key (#38) @mlflr

#### 🧺 Miscellaneous

* chore: update resource collection policy (#40) @mlflr
* chore: update DatadogAWSIntegrationRole policy (#39) @mlflr

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-datadog/compare/v0.8.5...v0.9.0

## v0.8.5 - 2024-10-02

### What's Changed

#### 🐛 Bug Fixes

* fix: Bump minimum required DD provider as extended resource collection field was added in 3.39.0 (#36) @stefanwb

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-datadog/compare/v0.8.4...v0.8.5

## v0.8.4 - 2024-09-25

### What's Changed

#### 🐛 Bug Fixes

* bug: resource_collection logic fix (#35) @Plork

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-datadog/compare/v0.8.3...v0.8.4

## v0.8.3 - 2024-09-17

### What's Changed

#### 🐛 Bug Fixes

* fix: policy should still be created without enabling cloud security (#34) @Plork

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-datadog/compare/v0.8.2...v0.8.3

## v0.8.2 - 2024-08-21

### What's Changed

#### 🐛 Bug Fixes

* bug: cannot be empty for policies (#33) @Plork

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-datadog/compare/v0.8.1...v0.8.2

## v0.8.1 - 2024-08-21

### What's Changed

#### 🐛 Bug Fixes

* bug: correct arn of policy! (#32) @Plork

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-datadog/compare/v0.8.0...v0.8.1

## v0.8.0 - 2024-08-20

### What's Changed

#### 🚀 Features

* feat: additional AWS resource collection IAM policy (#31) @Plork

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-datadog/compare/v0.7.1...v0.8.0

## v0.7.1 - 2024-08-15

### What's Changed

#### 🐛 Bug Fixes

* fix: Dependency fixes. (#30) @fatbasstard

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-datadog/compare/v0.7.0...v0.7.1

## v0.7.0 - 2024-07-08

### What's Changed

#### 🚀 Features

* feature: Add metrics tag filter (#29) @fatbasstard

#### 🐛 Bug Fixes

* fix: correct policy ARN (#28) @Plork

#### 📖 Documentation

* feature: Add metrics tag filter (#29) @fatbasstard

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-datadog/compare/v0.6.0...v0.7.0

## v0.6.0 - 2024-07-05

### What's Changed

#### 🚀 Features

* feat: enable Datadog resource collection for cloud security (#27) @Plork

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-datadog/compare/v0.5.0...v0.6.0

## v0.5.0 - 2024-06-03

### What's Changed

#### 🚀 Features

* feature: Add configuration of the enabled namespaces (#25) @fatbasstard

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-datadog/compare/v0.4.0...v0.5.0

## v0.4.0 - 2023-12-06

### What's Changed

#### 🚀 Features

* fix: Let datadog_integration_aws_log_collection depend on the cloudformation stack to prevent deployment issues & refactoring module (#24) @jschilperoord

#### 🐛 Bug Fixes

* fix: Let datadog_integration_aws_log_collection depend on the cloudformation stack to prevent deployment issues & refactoring module (#24) @jschilperoord

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-datadog/compare/v0.3.12...v0.4.0
