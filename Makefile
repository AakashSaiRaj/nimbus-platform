TF_DIR := infrastructure/envs/dev

.PHONY: init
init:
	cd $(TF_DIR) && terraform init
	@helm repo add eks https://aws.github.io/eks-charts 2>/dev/null || true
	@helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
	@helm repo update

.PHONY: plan
plan: init
	cd $(TF_DIR) && terraform plan

.PHONY: apply
apply: init
	cd $(TF_DIR) && terraform apply

.PHONY: kubeconfig
kubeconfig:
	aws eks update-kubeconfig --name nimbus-dev --region us-east-1

.PHONY: destroy
destroy:
	-kubectl delete ingress --all -A --timeout=60s
	sleep 30
	cd $(TF_DIR) && terraform destroy

.PHONY: argocd-password
argocd-password:
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
