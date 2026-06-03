#!/usr/bin/env bash
#
# Fetches Datadog AWS integration accounts and emits an HCL `locals` block
# mapping `aws_account_id` -> Datadog integration config ID.
#
# Required environment variables:
#   DD_API_KEY  Datadog API key
#   DD_APP_KEY  Datadog application key
#
# Optional environment variables:
#   DD_SITE     Datadog site host (default: api.datadoghq.eu)
#
# Usage:
#   ./import_config_ids.sh

set -euo pipefail

: "${DD_API_KEY:?DD_API_KEY is required}"
: "${DD_APP_KEY:?DD_APP_KEY is required}"
DD_SITE="${DD_SITE:-api.datadoghq.eu}"

for cmd in curl jq; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "error: '$cmd' is required but not installed" >&2
    exit 1
  fi
done

response="$(
  curl -sS --fail-with-body \
    -X GET "https://${DD_SITE}/api/v2/integration/aws/accounts" \
    -H "Accept: application/json" \
    -H "DD-API-KEY: ${DD_API_KEY}" \
    -H "DD-APPLICATION-KEY: ${DD_APP_KEY}"
)"

jq -r '
  "locals {",
  "  dd_aws_integration_ids = {",
  (
    .data
    | sort_by(.attributes.aws_account_id)
    | .[]
    | "    \"\(.attributes.aws_account_id)\" = \"\(.id)\""
  ),
  "  }",
  "}"
' <<<"$response"
