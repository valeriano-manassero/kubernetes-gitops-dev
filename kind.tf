resource "kind_cluster" "main_cluster" {
    name            = var.main_cluster_name
    kubeconfig_path = pathexpand(var.kubernetes_config_file)
    wait_for_ready  = true
  kind_config {
      kind        = "Cluster"
      api_version = "kind.x-k8s.io/v1alpha4"

      node {
          role = "control-plane"
          image = "kindest/node:v1.27.1"
          kubeadm_config_patches = [
            <<-EOT
              kind: InitConfiguration
              nodeRegistration:
                kubeletExtraArgs:
                  node-labels: "ingress-ready=true"
            EOT
          ]
          extra_port_mappings {
            container_port = 32080
            host_port      = 80
          }
          extra_port_mappings {
            container_port = 32443
            host_port      = 443
          }
      }
  }
}

