provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "null_resource" "kind_cluster" {
  provisioner "local-exec" {
    command = <<EOT
      kind create cluster --name smartgridflow --config ../kind-config.yaml
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}
