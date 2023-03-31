# List of variables which can be provided ar runtime to override the specified defaults 

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  nullable    = false
}

variable "name" {
  description = "Service name"
  type        = string
  default     = "restme"
}

variable "domain" {
  description = "Domain name"
  type        = string
  nullable    = false
}

variable "image" {
  description = "URI of the container image to deploy"
  type        = string
  nullable    = false
}

variable "regions" {
  description = "list of GPC regions to deploy to"
  type        = list(any)
  default     = ["us-west1", "europe-west1", "asia-east1"]
}

variable "log_level" {
  type        = string
  description = "Level of logging to use in the container (e.g. panic, fatal, error, warn, info, debug, trace)"
  default     = "info"
}

variable "alert_email" {
  type        = string
  description = "Email address to which alerts will be sent"
  nullable    = false
}