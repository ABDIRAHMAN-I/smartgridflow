resource "helm_release" "postgresql" {
  name       = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "12.8.4"  

  namespace  = "default"

  set {
    name  = "auth.username"
    value = "smartuser"
  }

  set {
    name  = "auth.password"
    value = "smartpass"
  }

  set {
    name  = "auth.database"
    value = "smartgrid"
  }

  set {
    name  = "primary.persistence.enabled"
    value = "false"  # disables PVC for now (simpler for local testing)
  }

  depends_on = [helm_release.kafka]
}
