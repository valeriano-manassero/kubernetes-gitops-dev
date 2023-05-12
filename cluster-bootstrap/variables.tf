variable "main_cluster_name" {
  type        = string
  description = "Main kubernetes cluster name"
  default     = "test-cluster"
}

variable "kubernetes_config_file" {
  type        = string
  description = "The Kubernetes config-file to be used"
  default     = "~/.kube/config"
}

variable "argocd_admin_password" {
  type        = string
  description = "Admin argocd password"
  default     = "admin"
}

variable "argocd_hostname" {
  type        = string
  description = "Argocd hostname"
  default     = "argocd.127-0-0-1.nip.io"
}