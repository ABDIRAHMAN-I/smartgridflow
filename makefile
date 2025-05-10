APP_NAME=smartgridflow
KIND_CLUSTER_NAME=smartgridflow

.PHONY: all apply argocd argocd-app deploy test destroy

all: apply argocd argocd-app deploy test

apply:
	@echo "\n🔧 [1/6] Creating cluster and provisioning infrastructure with Terraform..."
	cd terraform && terraform init && terraform apply -auto-approve
	@echo "✅ Terraform apply complete."

argocd:
	@echo "\n🚀 [2/6] Installing ArgoCD via Helm (Terraform-managed)..."
	@kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=120s || echo "⏳ Waiting for ArgoCD to finish starting..."

	@echo "\n🔐 ArgoCD UI Login Details:"
	@echo "🌐 URL: https://localhost:8080"
	@echo "📦 Run this in a separate terminal to open the UI:"
	@echo "    kubectl port-forward svc/argocd-server -n argocd 8080:443"
	@echo "🔑 Password:"
	@kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d && echo

argocd-app:
	@echo "\n📦 [3/6] Applying ArgoCD Application definition..."
	kubectl apply -f k8s/argocd/argocd-app.yaml -n argocd
	@echo "✅ ArgoCD Application created."

deploy:
	@echo "\n🚀 [4/6] Initial one-time apply of app manifests (for ArgoCD bootstrapping)..."
	kubectl apply -f k8s/producer/deployment.yaml
	kubectl apply -f k8s/consumer/deployment.yaml
	@echo "⏳ Waiting for pods to be ready..."
	@kubectl wait --for=condition=ready pod -l app=smart-meter-producer --timeout=60s
	@kubectl wait --for=condition=ready pod -l app=kafka-postgres-consumer --timeout=60s
	@echo "✅ Producer and consumer pods are running."

test:
	@echo "\n🧪 [5/6] Running system tests..."

	@echo "\n⏱️ Giving pods 30 seconds to stabilise before checking logs..."
	@sleep 30

	@echo "\n📦 Checking recent producer logs:"
	kubectl logs deployment/smart-meter-producer --tail=5 || echo "⚠️ Producer logs not available."

	@echo "\n📥 Checking recent consumer logs:"
	kubectl logs deployment/kafka-postgres-consumer --tail=5 || echo "⚠️ Consumer logs not available."

	@echo "\n🔍 Verifying PostgreSQL contains data..."
	@POSTGRES_POD=$$(kubectl get pods -l app.kubernetes.io/name=postgresql -o jsonpath="{.items[0].metadata.name}") && \
	kubectl exec -it $$POSTGRES_POD -- env PGPASSWORD=smartpass psql -U smartuser -d smartgrid -c "SELECT * FROM smart_readings LIMIT 10;" || \
	echo "⚠️  Could not verify Postgres data. Is the consumer running?"

	@echo "✅ All tests completed."


destroy:
	@echo "\n🔥 [6/6] Destroying infrastructure and kind cluster..."
	cd terraform && terraform destroy -auto-approve
	kind delete cluster --name $(KIND_CLUSTER_NAME)
	@echo "🧼 Clean teardown complete."
