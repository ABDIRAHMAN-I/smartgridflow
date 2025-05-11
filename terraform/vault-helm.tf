resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = "vault"
  version    = "0.27.0"

  create_namespace = true

  set {
    name  = "server.dev.enabled"
    value = "true"
  }

    depends_on = [
    null_resource.kind_cluster
    ]
}
