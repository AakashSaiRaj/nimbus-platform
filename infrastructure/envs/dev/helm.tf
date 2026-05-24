# AWS Load Balancer Controller — turns Kubernetes Ingress objects into ALBs.
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "3.3.0"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  # Annotation links the SA to the IRSA role.
  # The dot inside the annotation key is escaped because Helm's `set` syntax
  # uses dots for nested keys.
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.alb_controller_irsa.iam_role_arn
  }

  # Don't try to install before EKS + addons are fully ready.
  depends_on = [module.eks]
}

# Argo CD — GitOps engine.
resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.5.15"
  namespace        = "argocd"
  create_namespace = true

  # Non-HA: 1 replica each. Smaller footprint for dev.
  set {
    name  = "controller.replicas"
    value = "1"
  }

  set {
    name  = "redis-ha.enabled"
    value = "false"
  }
  set {
  name  = "configs.params.server\\.insecure"
  value = "true"
}


  depends_on = [module.eks]
}
