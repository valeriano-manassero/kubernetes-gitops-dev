provider "kubectl" {
  load_config_file  = true
  config_path       = kind_cluster.main_cluster.kubeconfig_path
}

data "http" "kind_ingress_nginx" {
  url = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"
}

data "kubectl_file_documents" "ingress_nginx_yaml_files" {
    content = data.http.kind_ingress_nginx.response_body
}

resource "kubectl_manifest" "ingress_nginx" {
  provider   = kubectl
  for_each   = data.kubectl_file_documents.ingress_nginx_yaml_files.manifests
  yaml_body  = each.value
  wait       = true
  depends_on = [ kind_cluster.main_cluster ]
}

resource "kubectl_manifest" "argocd_apps" {
  provider   = kubectl
  for_each   = fileset(path.module, "argocd-apps/*.yaml")
  yaml_body  = file("${path.module}/${each.key}")
  wait       = true
  depends_on = [ kubectl_manifest.ingress_nginx ]
}
