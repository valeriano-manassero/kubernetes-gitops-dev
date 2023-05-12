provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kubernetes_config_file)
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.33.1"
  namespace  = "argocd"
  create_namespace = true
  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = bcrypt(var.argocd_admin_password)
  }
  set {
    name  = "configs.params.server\\.insecure"
    value = true
  }
  set {
    name  = "server.ingress.enabled"
    value = true
  }
  set {
    name  = "server.ingress.hosts"
    value = join("", ["{", var.argocd_hostname, "}"])
  }
  depends_on = [ kubectl_manifest.ingress_nginx ]
}
