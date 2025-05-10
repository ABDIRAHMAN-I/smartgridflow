resource "helm_release" "kafka" {
  name       = "kafka"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kafka"
  version    = "26.3.2" # or latest stable

  set {
    name  = "replicaCount"
    value = "1"
  }

  set {
    name  = "listeners.client.protocol"
    value = "PLAINTEXT"
  }

  set {
    name  = "auth.enabled"
    value = "false"
  }

  namespace  = "default"
  depends_on = [null_resource.kind_cluster]
}
