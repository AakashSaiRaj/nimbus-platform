resource "null_resource" "root_app_bootstrap" {
  triggers = {
    # Re-apply if the root-app.yaml content changes
    manifest_sha = filesha256("${path.module}/../../../gitops/root-app.yaml")
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig --name ${module.eks.cluster_name} --region us-east-1
      kubectl apply -f ${path.module}/../../../gitops/root-app.yaml
    EOT
  }

  depends_on = [helm_release.argocd]
}
