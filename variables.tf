variable "api_key" {
  type        = string
  default     = null
  description = "Datadog API key"
  sensitive   = true
}

variable "api_key_name" {
  type        = string
  default     = null
  description = "Name of the Datadog API key used if create_api_key is set to true, otherwise ignored"

  validation {
    condition     = !var.create_api_key || try(length(var.api_key_name), 0) > 0
    error_message = "The api_key_name value must be set if create_api_key is set to true."
  }
}

variable "cspm_resource_collection_enabled" {
  type        = bool
  default     = false
  description = "Whether Datadog collects cloud security posture management resources from your AWS account."
}

variable "create_api_key" {
  type        = bool
  default     = false
  description = "Set to true to have this module create a Datadog API key. Warning: Datadog allows a maximum of 50 API keys per organization by default."
}

variable "datadog_tags" {
  type        = list(string)
  default     = []
  description = "Array of tags (in the form key:value) to add to all hosts and metrics"
}

variable "extended_resource_collection_enabled" {
  type        = bool
  default     = false
  description = "Whether Datadog collects additional attributes and configuration information about the resources in your AWS account"
}

variable "included_regions" {
  type        = list(string)
  default     = []
  description = "List of regions to be included for metrics collection in Datadog integration. If empty, all regions are included."
}

variable "install_log_forwarder" {
  type        = bool
  default     = false
  description = "Set to true to install the Datadog Log Forwarder (requires var.api_key to be set)"

  validation {
    condition     = !var.install_log_forwarder || var.create_api_key || try(length(var.api_key), 0) > 0
    error_message = "The api_key value must be set or create_api_key has to be enabled if install_log_forwarder is set to true."
  }
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
  default     = null
  description = "AWS log forwarder reserved concurrency"
}

variable "log_forwarder_layer_version" {
  type        = string
  default     = "latest"
  description = "AWS log forwarder layer version to install"
}

variable "metric_tag_filters" {
  type        = map(string)
  default     = {}
  description = "A list of namespaces and a tag filter query to filter metric collection of resources"

  validation {
    condition     = alltrue([for namespace in keys(var.metric_tag_filters) : contains(["elb", "application_elb", "sqs", "rds", "custom", "network_elb", "lambda"], namespace)])
    error_message = "Allowed values for namespace are \"elb\", \"application_elb\", \"sqs\", \"rds\", \"custom\", \"network_elb\" or \"lambda\"."
  }
}

variable "namespace_filters" {
  type = object({
    exclude_only = optional(list(string), null)
    include_only = optional(list(string), null)
  })
  default = {
    exclude_only = ["AWS/SQS", "AWS/ElasticMapReduce", "AWS/Usage"]
  }
}

variable "site_url" {
  type        = string
  default     = "datadoghq.eu"
  description = "Define your Datadog Site to send data to. For the Datadog US site, set to datadoghq.com"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the bucket"
  default     = {}
}
