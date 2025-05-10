APP_NAME=smartgridflow
KIND_CLUSTER_NAME=smartgridflow

.PHONY: all apply build deploy test destroy

all: apply build deploy test

apply:
	@echo "\n🔧 [1/5] Creating cluster and provisioning infrastructure with Terraform..."
	cd terraform && terraform init && terraform apply -auto-approve
	@echo "✅ Terraform apply complete."

build:
	@echo "\n🐳 [2/5] Building and loading Docker images into kind..."
	docker build -t $(APP_NAME)-producer:latest ./producer
	docker build -t $(APP_NAME)-consumer:latest ./consumer
	kind load docker-image $(APP_NAME)-producer:latest --name $(KIND_CLUSTER_NAME)
	kind load docker-image $(APP_NAME)-consumer:latest --name $(KIND_CLUSTER_NAME)
	@echo "✅ Docker images built and loaded into kind."

deploy:
	@echo "\n🚀 [3/5] Deploying producer and consumer apps to Kubernetes..."
	kubectl apply -f k8s/producer/deployment.yaml
	kubectl apply -f k8s/consumer/deployment.yaml
	@echo "⏳ Waiting for pods to be ready..."
	@kubectl wait --for=condition=ready pod -l app=smart-meter-producer --timeout=60s
	@kubectl wait --for=condition=ready pod -l app=kafka-postgres-consumer --timeout=60s
	@echo "✅ Producer and consumer pods are running."

test:
	@echo "\n🧪 [4/5] Running system tests..."

	@echo "\n📦 Checking recent producer logs:"
	kubectl logs deployment/smart-meter-producer --tail=5

	@echo "\n📥 Checking recent consumer logs:"
	kubectl logs deployment/kafka-postgres-consumer --tail=5

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
