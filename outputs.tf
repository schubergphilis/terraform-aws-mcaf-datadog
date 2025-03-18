output "api_key" {
  description = "Datadog API key if created by the module"
  value       = var.create_api_key ? datadog_api_key.default[0].key : null
  sensitive   = true
}

output "forwarder_arn" {
  description = "Datadog log forwarder lambda ARN"
  value       = var.install_log_forwarder ? aws_cloudformation_stack.datadog_forwarder[0].outputs["DatadogForwarderArn"] : ""
}
