variable "datadog_tags" {
  type        = list(string)
  default     = []
  description = "Array of tags (in the form key:value) to add to all hosts and metrics"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the bucket"
}
