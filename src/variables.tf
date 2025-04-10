variable "region" {
  description = "AWS Region"
  type        = string
}

variable "addon_name" {
  type        = string
  description = "The name of the EKS addon"
}

variable "addon_version" {
  type        = string
  description = "The version of the EKS addon"
  default     = null
}

variable "configuration_values" {
  type        = map(string)
  description = "The configuration values for the EKS addon"
  default     = {}
}

variable "kubernetes_namespace" {
  type        = string
  description = "The Kubernetes namespace for the EKS addon"
  default     = "kube-system"
}

variable "resolve_conflicts_on_create" {
  type        = string
  description = "How to resolve conflicts on addon creation"
  default     = null
}

variable "resolve_conflicts_on_update" {
  type        = string
  description = "How to resolve conflicts on addon update"
  default     = null
}

variable "create_timeout" {
  type        = string
  description = "The timeout to create the EKS addon"
  default     = "15m"
}

variable "update_timeout" {
  type        = string
  description = "The timeout to update the EKS addon"
  default     = "15m"
}

variable "delete_timeout" {
  type        = string
  description = "The timeout to delete the EKS addon"
  default     = "15m"
}

variable "additional_policy_arns" {
  type        = list(string)
  description = "Additional policy ARNs to attach to the EKS addon service account"
  default     = []
}

variable "priority_class_enabled" {
  type        = bool
  description = "Whether to enable the priority class for the EKS addon"
  default     = false
}
