variable "datadog_tags" {
  type        = list(string)
  default     = []
  description = "Tags (format of key:value) to add to all metrics retrieved from the datadog aws integration"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the bucket"
}
