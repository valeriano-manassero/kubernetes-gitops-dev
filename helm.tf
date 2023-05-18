provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kubernetes_config_file)
  }
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = "1.17.2"
  namespace  = "istio-system"
  create_namespace = true
  depends_on = [ kind_cluster.main_cluster ]
}

resource "helm_release" "istio_istiod" {
  name       = "istio-istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.17.2"
  namespace  = "istio-system"
  create_namespace = true
  values = [
    <<-EOT
      meshConfig:
        ingressClass: istio
        ingressControllerMode: DEFAULT
        ingressSelector: ingress
    EOT
  ]
  depends_on = [ helm_release.istio_base ]
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = "1.17.2"
  namespace  = "istio-ingress"
  create_namespace = true
  values = [
    <<-EOT
      nodeSelector:
        ingress-ready: "true"
      service:
        type: NodePort
        ports:
        - name: status-port
          port: 15021
          protocol: TCP
          targetPort: 15021
        - name: http2
          port: 80
          protocol: TCP
          targetPort: 80
          nodePort: 32080
        - name: https
          port: 443
          protocol: TCP
          targetPort: 443
          nodePort: 32443
      autoscaling:
        enabled: false
    EOT
  ]
  depends_on = [ helm_release.istio_istiod ]
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
  depends_on = [ helm_release.istio_ingress ]
}
