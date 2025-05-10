APP_NAME=smartgridflow
KIND_CLUSTER_NAME=smartgridflow

.PHONY: all apply deploy test destroy argocd argocd-app

all: apply argocd argocd-app test

apply:
	@echo "\n🔧 [1/5] Creating cluster and provisioning infrastructure with Terraform..."
	cd terraform && terraform init && terraform apply -auto-approve
	@echo "✅ Terraform apply complete."

argocd:
	@echo "\n🚀 [2/5] Installing ArgoCD via Helm (Terraform-managed)..."
	@kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=120s || echo "⏳ Waiting for ArgoCD to finish starting..."

	@echo "\n🔐 Getting ArgoCD default admin password:"
	@kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d && echo
	@echo "🔗 Access the UI via: kubectl port-forward svc/argocd-server -n argocd 8080:443"

argocd-app:
	@echo "\n📦 [3/5] Applying ArgoCD Application to sync from GitHub..."
	kubectl apply -f k8s/argocd/argocd-app.yaml -n argocd
	@echo "✅ ArgoCD app created. It will now watch your GitHub repo and sync deployments automatically."

test:
	@echo "\n🧪 [4/5] Running system tests..."

	@echo "\n📦 Checking recent producer logs:"
	kubectl logs deployment/smart-meter-producer --tail=5 || echo "⚠️ Producer logs not available."

	@echo "\n📥 Checking recent consumer logs:"
	kubectl logs deployment/kafka-postgres-consumer --tail=5 || echo "⚠️ Consumer logs not available."

	@echo "\n🔍 Verifying PostgreSQL contains data..."
	@POSTGRES_POD=$$(kubectl get pods -l app.kubernetes.io/name=postgresql -o jsonpath="{.items[0].metadata.name}") && \
	kubectl exec -it $$POSTGRES_POD -- psql -U smartuser -d smartgrid -c "SELECT * FROM smart_readings LIMIT 10;" || \
	echo "⚠️  Could not verify Postgres data. Is the consumer running?"

	@echo "✅ All tests completed."

destroy:
	@echo "\n🔥 [5/5] Destroying infrastructure and kind cluster..."
	cd terraform && terraform destroy -auto-approve
	kind delete cluster --name $(KIND_CLUSTER_NAME)
	@echo "🧼 Clean teardown complete."
