variable "api_key" {
  type        = string
  default     = null
  description = "Datadog API key"
}

variable "datadog_tags" {
  type        = list(string)
  default     = []
  description = "Array of tags (in the form key:value) to add to all hosts and metrics"
}

variable "install_log_forwarder" {
  type        = bool
  default     = false
  description = "Set to true to install the Datadog Log Forwarder (requires var.api_key to be set)"
}

variable "log_collection_services" {
  type        = list(string)
  default     = null
  description = "A list of services to collect logs from. Valid values are s3/elb/elbv2/cloudfront/redshift/lambda."
}

variable "log_forwarder_name" {
  type        = string
  default     = "datadog-forwarder"
  description = "AWS log forwarder lambda name"
}

variable "log_forwarder_reserved_concurrency" {
  type        = number
  default     = 100
  description = "AWS log forwarder reserved concurrency"
}

variable "log_forwarder_version" {
  type        = string
  default     = "latest"
  description = "AWS log forwarder version to install"
}

variable "site_url" {
  type        = string
  default     = "datadoghq.eu"
  description = "Define your Datadog Site to send data to. For the Datadog US site, set to datadoghq.com"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the bucket"
}
