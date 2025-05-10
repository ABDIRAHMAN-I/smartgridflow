resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.19.15"

  namespace          = "argo-cd"
  create_namespace   = true
  timeout            = 600

}
