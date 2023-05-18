provider "kubectl" {
  load_config_file  = true
  config_path       = kind_cluster.main_cluster.kubeconfig_path
}

resource "kubectl_manifest" "argocd_apps" {
  provider   = kubectl
  for_each   = fileset(path.module, "argocd-apps/*.yaml")
  yaml_body  = file("${path.module}/${each.key}")
  wait       = true
  depends_on = [ helm_release.argocd ]
}
