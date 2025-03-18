output "forwarder_arn" {
  description = "Datadog log forwarder lambda ARN"
  value       = var.install_log_forwarder ? aws_cloudformation_stack.datadog_forwarder[0].outputs["DatadogForwarderArn"] : ""
}
