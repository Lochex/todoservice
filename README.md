# Todo App

The todo app is a simple Flask application written in `Python 3.12` that allows
users to create todos via a REST API. See the application code in `src/` to
understand how the application works and how the data model is defined.

## Quick Start

### Run the plain app

To run the app locally, please adhere to the following steps.
The application will serve its API on port 8082.

```bash
# Setup your Python environment and install dependencies
pip install poetry
poetry install

# Set environment variables which the app expects
APP_DATABASE_URL="sqlite:///test.db" # option for local sqlite database
OTEL_EXPORTER_OTLP_ENDPOINT="dummy" # not important if not using OpenTelemetry
OTEL_TRACES_EXPORTER=none # To prevent error logs when not using OpenTelemetry

# Run application locally
poetry run gunicorn "src.app:main()" --bind=0.0.0.0:8082
```

### Run the app with OpenTelemetry

When running the application with the OpenTelemetry exporter, we follow a
similar setup which additionally requires to define the endpoint of a
OpenTelemetry collector. Subsequently, the app is run with the OpenTelemetry
auto-instrumentation.

```bash
pip install poetry
poetry install

# Set environment variables which the app expects
APP_DATABASE_URL="sqlite:///test.db" # option for local sqlite database
OTEL_EXPORTER_OTLP_ENDPOINT="<host>:4317" # here define the OpenTelemetry endpoint

# Run application locally
poetry run opentelemetry-bootstrap -a install
poetry run opentelemetry-instrument gunicorn "src.app:main()" --bind=0.0.0.0:8082 -c src/gunicorn.conf.py
```

## OpenTelemetry Collector

A collector component is required for the app to sent telemetry data to.
We recommend using the existing [grafana/otel-lgtm](https://github.com/grafana/docker-otel-lgtm)
Docker image.

# To-do Service Architecture

This repository hosts a Python-based To-do service that is auto-instrumented using OpenTelemetry and deployed on Azure Kubernetes Service (AKS). The infrastructure is provisioned using Terraform, and CI/CD is managed via GitHub Actions. The architecture follows a **Public Service vs. Private Database** model, ensuring that the application is publicly accessible while the database remains secured within a virtual network.

## Architecture Overview

### Application
- **Language & Framework:**  
  A Python (Flask) based To-do service.
- **Instrumentation:**  
  Auto-instrumented using OpenTelemetry via `opentelemetry-distro` and `opentelemetry-instrument`.
- **Telemetry Export:**  
  Telemetry data (traces, metrics, logs) is exported using the OTLP exporter to an OpenTelemetry backend.

### Deployment
- **Containerization:**  
  The application is containerized with Docker using Poetry for dependency management.
- **Cluster:**  
  Deployed to an AKS cluster within a private virtual network (VNet).
- **Ingress:**  
  A public Ingress controller (Traefik) exposes the service via a custom domain (e.g., `test.example.com`).
- **Service Exposure:**  
  The application is exposed internally using a ClusterIP Service. External traffic is routed via the Ingress controller.

### Database
- **Service:**  
  Azure Database for PostgreSQL (Single Server) is used as the persistent data store.
- **Security:**  
  The database is secured by:
  - Deploying the AKS cluster within a VNet.
  - Using either service endpoints with firewall rules or private endpoints (if needed) so that only traffic from trusted IP ranges (e.g., the AKS node subnet) is allowed.
- **Connection:**  
  The application connects to PostgreSQL using a connection string that includes the fully qualified domain name (FQDN) provided by Azure.

### Observability
- **OpenTelemetry Collector:**  
  The [grafana/otel-lgtm](https://github.com/grafana/docker-otel-lgtm) image is used to deploy an OpenTelemetry Collector that gathers telemetry data.
- **Grafana Dashboards:**  
  Grafana (part of the otel-lgtm service) is used to visualize key metrics such as error rate and latency. Pre-configured dashboards (imported via JSON) display these metrics.

### CI/CD & Infrastructure Provisioning
- **Terraform:**  
  Used to provision all Azure resources including AKS, VNet, PostgreSQL, and ACR.
- **GitHub Actions:**  
  Automates container builds, pushes images to ACR, and applies Kubernetes manifests to the AKS cluster.

## Request Flow

1. **External Requests:**
   - Users access the application via `http://test.example.com/todos`.
   - DNS or local `/etc/hosts` maps `test.example.com` to the public IP of the Ingress controller.
   
2. **Ingress Routing:**
   - The Ingress controller (Traefik) receives requests and routes them to the internal ClusterIP Service (`todo-service`).

3. **Application Processing & Telemetry:**
   - The To-do service processes requests and auto-instrumentation captures telemetry data (traces, metrics, logs).
   - Telemetry data is exported via OTLP to the OpenTelemetry Collector.
   
4. **Database Connectivity:**
   - The application connects securely to Azure PostgreSQL using a connection string
   - The database is restricted by firewall rules (or service endpoints) to allow only traffic from the trusted AKS node subnet.

5. **Monitoring & Visualization:**
   - Grafana dashboards, accessible through the otel-collector service (typically on port 3000), display the telemetry data.
   - Dashboards show metrics such as error rates and latency, providing insight into application performance.

## Running Locally & in Production

- **Local Development:**  
  You can use Docker Compose to run the application along with local instances of PostgreSQL and the otel-lgtm service for testing purposes.
  
- **Production Deployment:**  
  Infrastructure is provisioned via Terraform, and application deployment uses Kubernetes manifests in AKS. The public Ingress (Traefik) exposes your service while the database remains secured inside the VNet.

## Getting Started

1. **Provision Infrastructure:**
   - Use Terraform to create your AKS cluster, VNet, PostgreSQL server, and other necessary resources.
2. **Deploy the Application:**
   - Build your container image using Poetry.
   - Push the image to your Azure Container Registry.
   - Deploy Kubernetes manifests (for the application, Ingress, etc.) to AKS.
3. **Monitor Telemetry:**
   - Access Grafana via the otel-collector service to view dashboards and monitor telemetry data.
