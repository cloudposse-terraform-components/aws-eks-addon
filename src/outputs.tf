output "addon_arn" {
  description = "The Amazon Resource Name (ARN) of the EKS addon"
  value       = local.enabled ? aws_eks_addon.this[0].arn : ""
}

output "addon_version" {
  description = "The version of the EKS addon"
  value       = local.enabled ? aws_eks_addon.this[0].addon_version : ""
}

output "priority_class_name" {
  description = "The name of the Kubernetes priority class (if enabled)"
  value       = local.priority_class_enabled ? kubernetes_priority_class.this[0].metadata[0].name : ""
}
