# ⚡ SmartGridFlow: A Cloud-Native Real-Time Smart-Meter Data Pipeline

**SmartGridFlow** is a cloud-native, real-time data pipeline that simulates and processes energy-usage data from smart meters — mirroring production-grade systems used by energy and infrastructure providers. It showcases real-time streaming with **Kafka**, Python-based processing, and persistent storage in **PostgreSQL**, all orchestrated via **Kubernetes** and **Terraform**.

---

## 📐 Architecture Diagram

```text
[ Smart Meter Simulator Pod ]
            |
 Kafka Topic: smart-meter-data
            |
   [ Kafka Consumer Pod ]
            |
     PostgreSQL Database
```

---

## 🚀 Tech Stack

- **Python** – Simulator and consumer applications  
- **Apache Kafka** – Real-time streaming platform  
- **PostgreSQL** – Persistent storage for smart-meter readings  
- **Docker** – Containerisation of all services  
- **Kubernetes (Kind)** – Local Kubernetes cluster for development  
- **Terraform** – Infrastructure-as-Code (deployed via Helm)  
- **Helm** – Simplified deployment of Kafka and PostgreSQL  
- **Makefile** – End-to-end automation of the pipeline  

---

## 📁 Folder Structure

```text
smartgridflow/
├── simulator/        # Smart-meter producer app
├── consumer/         # Kafka consumer app
├── terraform/        # Infrastructure provisioning (Kafka, Postgres)
├── k8s/              # Kubernetes deployment YAMLs
│   ├── producer/
│   └── consumer/
├── kind-config.yaml  # Kind cluster configuration
├── Makefile          # Automation commands
└── README.md         # Project documentation
```

---

## ⚙️ How It Works

1. **Simulator** (Python) generates synthetic smart-meter readings and publishes them to the Kafka topic `smart-meter-data` every few seconds.  
2. **Kafka** receives and buffers these messages on the `smart-meter-data` topic.  
3. **Consumer** (Python) subscribes to the topic, processes incoming messages, and writes the results to **PostgreSQL**.  
4. **PostgreSQL** stores the data for downstream analysis and visualisation.  
5. All components run as pods in a **Kubernetes (Kind)** cluster, provisioned by **Terraform** and deployed via **Helm**.  

---

## 🧪 Getting Started

### 🔧 Prerequisites

Ensure the following are installed locally:

- Docker  
- Terraform  
- Kind (Kubernetes-in-Docker)  
- Python 3.10 +  
- Make  

---

### 🚀 Run Everything

```bash
make all
```

`make all` will:  

1. Provision the Kind cluster.  
2. Deploy Kafka and PostgreSQL with Terraform + Helm.  
3. Build Docker images for the simulator and consumer.  
4. Load the images into the cluster.  
5. Deploy the simulator and consumer apps.  
6. Tail logs and verify that PostgreSQL is receiving data.  

---

### 📦 Makefile Commands

| Command         | Description                                                |
|-----------------|------------------------------------------------------------|
| `make all`      | Provision, build, deploy **and test** the entire pipeline  |
| `make apply`    | Run Terraform to set up infrastructure                     |
| `make build`    | Build Docker images and load them into the cluster         |
| `make deploy`   | Deploy simulator and consumer apps to Kubernetes           |
| `make test`     | Tail logs and confirm data is stored in PostgreSQL         |
| `make destroy`  | Tear down infrastructure and delete the Kind cluster       |

---

### 🔍 Testing the Pipeline

```bash
make test
```

This will:  

- Stream logs from the simulator and consumer pods.  
- Confirm that data is being ingested into PostgreSQL.  
- Verify end-to-end pipeline functionality.  

---

### 🧼 Cleaning Up

```bash
make destroy
```

This command will:  

- Run `terraform destroy` to remove Kafka, PostgreSQL, and other resources.  
- Delete the Kind cluster entirely, returning your system to a clean state.  

---

## 🤝 Contributing

Contributions are welcome! If you’d like to suggest improvements, raise issues, or add features (e.g. Prometheus metrics, Grafana dashboards, CI/CD workflows), please open an issue or submit a pull request.

---

## 📄 Licence

Distributed under the **MIT Licence** — feel free to use, modify, and adapt this project as needed.
