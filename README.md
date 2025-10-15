# 🐳 Hello Helm Chart — Barney Style Guide

This is a beginner-friendly, step-by-step guide to get your **first Helm chart** running on a Kubernetes cluster (kind, EKS, or AKS).

## 📁 Folder Structure

```bash
hello-chart/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── _helpers.tpl
    ├── deployment.yaml
    └── service.yaml
```

## 🪄 What this does

- Spins up a simple **Nginx Hello** web server using a Deployment.
- Exposes it with a Kubernetes Service.
- Deploys everything with a single Helm command.
- Includes a **test script** to lint, render, and check resources.

You’ll learn:
- Helm templating (_helpers.tpl)
- Rendering manifests (`helm template`)
- Installing / upgrading releases
- Port forwarding to test locally


## 🧰 Prerequisites

- kubectl installed and configured
- helm installed
- A running Kubernetes cluster (e.g. kind)

### Check:
```bash
kubectl version --client
helm version
kubectl get nodes
```

## 🚀 How to Deploy

### 1. Create a cluster (optional for local)
```bash
kind create cluster --name demo
kubectl get nodes
```

### 2. Lint the chart
```bash
helm lint .
```

### 3. Render manifests
```bash
helm template hello . | less
```

### 4. Install the chart
```bash
helm install hello .
```

### Check resources:
```bash
kubectl get all
```

## 🌐 Test It
Run the following command from the root of the directory.
```bash
./test.sh
```

### Option A: Port forward
```bash
kubectl port-forward svc/hello 8080:80
```

# open http://localhost:8080

### Option B: LoadBalancer (cloud)
```bash
kubectl patch svc hello -p '{"spec":{"type":"LoadBalancer"}}'
kubectl get svc hello -w
```

# open the EXTERNAL-IP in your browser


## 🔁 Upgrade or Rollback
```bash
helm upgrade hello ./hello-chart
helm history hello
helm rollback hello 1
```

## 🧹 Clean Up
```bash
helm uninstall hello
kubectl get all
kind delete cluster --name demo  # if using kind
```

## 🧠 Tips

- Use `helm template` to debug charts before installing.
- Use `helm uninstall` to clean up releases.
- Label and annotate resources for clean ownership.
- Use lowercase `metadata` in YAML — K8s is case-sensitive.

You just built, installed, and ran a Helm chart.

#### Next steps:
- Add Ingress
- Deploy on EKS or AKS
- Add ConfigMaps / Secrets
- Create values overrides for multiple environments
