module "prefix_and_tags" {
  source = "git@github.com:sebastiandaberdaku/terraform-modules.git//prefix-and-tags?ref=prefix-and-tags/v1.0.0"

  company     = var.company
  environment = var.environment
  team        = var.team
}

locals {
  k8s_labels = { for k, v in module.prefix_and_tags.tags : replace(trimspace(k), "/\\s/", "-") => replace(trimspace(v), "/\\s/", "-") }
}

resource "kubernetes_namespace_v1" "argo_cd" {
  count = var.create && (var.namespace != "kube-system") ? 1 : 0
  metadata {
    name = var.namespace
    labels = merge(
      local.k8s_labels,
      { "kubernetes.io/metadata.name" = var.namespace }
    )
  }
}

resource "kubernetes_secret_v1" "git_repo" {
  for_each   = var.create ? var.repositories : {}
  depends_on = [kubernetes_namespace_v1.argo_cd]
  metadata {
    name      = "${each.key}-repository-secret"
    namespace = var.namespace
    labels = merge(
      local.k8s_labels,
      { "argo-cd.argoproj.io/secret-type" = "repository" }
    )
  }
  data = {
    name          = each.key
    type          = each.value.type
    project       = each.value.project
    url           = each.value.url
    sshPrivateKey = sensitive(try(file(each.value.ssh_private_key_path), ""))
  }

  type      = "Opaque"
  immutable = true

  lifecycle {
    ignore_changes = [
      data["sshPrivateKey"]
    ]
  }
}

resource "helm_release" "argo_cd" {
  count       = var.create ? 1 : 0
  depends_on  = [kubernetes_namespace_v1.argo_cd]
  name        = "argo-cd"
  repository  = "https://argoproj.github.io/argo-helm"
  chart       = "argo-cd"
  version     = var.helm_chart_version
  namespace   = var.namespace
  max_history = 3
  timeout     = 900

  values = [file("${path.module}/values.yaml")]

  dynamic "set" {
    for_each = local.k8s_labels
    content {
      name  = "crds.additionalLabels.${set.key}"
      value = set.value
    }
  }
  dynamic "set" {
    for_each = local.k8s_labels
    content {
      name  = "global.additionalLabels.${set.key}"
      value = set.value
    }
  }
  dynamic "set" {
    for_each = local.k8s_labels
    content {
      name  = "redis-ha.labels.${set.key}"
      value = set.value
    }
  }
}

data "kubernetes_secret_v1" "admin_secret" {
  count = var.create ? 1 : 0
  metadata {
    name      = "argo-cd-initial-admin-secret"
    namespace = var.namespace
  }
}