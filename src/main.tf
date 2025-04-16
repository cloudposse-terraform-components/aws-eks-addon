locals {
  enabled = module.this.enabled

  priority_class_enabled = local.enabled && var.priority_class_enabled
  priority_class_name    = module.this.id
}

resource "aws_eks_addon" "this" {
  count = local.enabled ? 1 : 0

  addon_name                  = var.addon_name
  addon_version               = var.addon_version
  configuration_values        = jsonencode(var.configuration_values)
  resolve_conflicts_on_create = var.resolve_conflicts_on_create
  resolve_conflicts_on_update = var.resolve_conflicts_on_update

  cluster_name             = one(module.eks.outputs[*].eks_cluster_id)
  service_account_role_arn = module.eks_iam_role.service_account_role_arn

  tags = module.this.tags

  timeouts {
    create = var.create_timeout
    update = var.update_timeout
    delete = var.delete_timeout
  }

  depends_on = [module.eks_iam_role, kubernetes_priority_class.this]
}

module "eks_iam_role" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "2.2.1"

  enabled = local.enabled

  eks_cluster_oidc_issuer_url = module.eks.outputs.eks_cluster_identity_oidc_issuer

  service_account_name      = module.this.id
  service_account_namespace = var.kubernetes_namespace

  context = module.this.context
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = local.enabled ? toset(var.additional_policy_arns) : toset([])

  role       = module.eks_iam_role.service_account_role_name
  policy_arn = each.value
}

resource "kubernetes_priority_class" "this" {
  count = local.priority_class_enabled ? 1 : 0

  metadata {
    name = local.priority_class_name
  }

  value          = 1000000
  global_default = false
  description    = "Priority class for the ${module.this.id} EKS addon"
}
