# 🚀 BUILD INSTRUCTIONS

## Quick Build (5 Minutes)

### Step 1: Setup Minikube
```bash
cd ~/k8s-production-project
./scripts/setup.sh
```

### Step 2: Build Docker Image
```bash
./scripts/build.sh
```

### Step 3: Scan Image (Optional)
```bash
./scripts/scan-image.sh
```

### Step 4: Deploy Application
```bash
./scripts/deploy.sh
```

### Step 5: Test Application
```bash
./scripts/test.sh
```

### Step 6: Access Externally
```bash
# Terminal 1: Start tunnel
minikube tunnel

# Terminal 2: Add to hosts and test
echo "$(minikube ip) api.local" | sudo tee -a /etc/hosts
curl http://api.local/
curl http://api.local/api/data
```

---

## Manual Build (Step by Step)

### 1. Start Minikube
```bash
minikube start --cpus=4 --memory=8192 --driver=docker
minikube addons enable ingress
minikube addons enable metrics-server
```

### 2. Build Image
```bash
cd app/
docker build -t api-app:v1.0 .
minikube image load api-app:v1.0
```

### 3. Deploy
```bash
cd ..
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-deployment.yaml
kubectl apply -f k8s/03-service.yaml
kubectl apply -f k8s/04-hpa.yaml
kubectl apply -f k8s/05-ingress.yaml
```

### 4. Verify
```bash
kubectl get pods -n production-api
kubectl get svc -n production-api
kubectl get hpa -n production-api
kubectl get ingress -n production-api
```

---

## Testing Features

### Self-Healing Test
```bash
# Kill a pod
kubectl delete pod -l app=api -n production-api --force

# Watch recovery
kubectl get pods -n production-api -w
```

### Auto-Scaling Test
```bash
# Generate load (install hey first: go install github.com/rakyll/hey@latest)
hey -z 5m -c 100 http://api.local/api/data

# Watch scaling
kubectl get hpa -n production-api -w
```

### Security Test
```bash
# Scan image
trivy image --severity HIGH,CRITICAL api-app:v1.0
```

---

## Troubleshooting

### Pods not starting
```bash
kubectl describe pod -n production-api <pod-name>
kubectl logs -n production-api <pod-name>
```

### Metrics not available
```bash
# Wait 2-3 minutes after enabling metrics-server
kubectl top nodes
kubectl top pods -n production-api
```

### Ingress not working
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Ensure tunnel is running
minikube tunnel
```

---

## Cleanup

```bash
kubectl delete namespace production-api
minikube stop
minikube delete
```

---

## Next Steps

1. ✅ Install OPA Gatekeeper (Phase 6)
2. ✅ Apply security policies
3. ✅ Load test and tune
4. ✅ Document your results
5. ✅ Post on LinkedIn!
