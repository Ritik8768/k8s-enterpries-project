# 🚀 Production Kubernetes System - Quick Guide

## What You Get

A production-ready Kubernetes application with:
- Self-healing (auto-restart on crash)
- Auto-scaling (2-10 pods based on load)
- Security scanning (Trivy)
- Load balancing (NGINX Ingress)

## Setup (10 Minutes)

### 1. Start Minikube
```bash
minikube start --cpus=4 --memory=8192
minikube addons enable ingress
minikube addons enable metrics-server
```

### 2. Build Application
```bash
eval $(minikube docker-env)
cd app
docker build -t api-app:v1.0 .
```

### 3. Deploy
```bash
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-deployment.yaml
kubectl apply -f k8s/03-service.yaml
kubectl apply -f k8s/04-hpa.yaml
kubectl apply -f k8s/05-ingress.yaml
```

### 4. Access
```bash
echo "$(minikube ip) api.local" | sudo tee -a /etc/hosts
```

Open browser: **http://api.local**

## Test Auto-Scaling

```bash
# Install Locust
pip3 install locust

# Run load test
locust -f tests/locustfile.py --host=http://api.local

# Watch scaling
kubectl get hpa -n production-api -w
```

## Useful Commands

```bash
# View pods
kubectl get pods -n production-api

# View logs
kubectl logs -n production-api -l app=api

# Check metrics
kubectl top pods -n production-api

# Test self-healing
kubectl delete pod -n production-api -l app=api --force
```

## Cleanup

```bash
kubectl delete namespace production-api
minikube stop
```

## Troubleshooting

**Pods not starting?**
```bash
kubectl describe pod -n production-api <pod-name>
```

**Can't access in browser?**
```bash
# Check ingress
kubectl get ingress -n production-api

# Verify hosts file
cat /etc/hosts | grep api.local
```

---

**Need help?** Check the main README.md
