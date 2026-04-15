# ⚡ Quick Start Guide

## 🎯 Get Running in 10 Minutes

### Step 1: Clone Repository (1 min)
```bash
git clone https://github.com/YOUR_USERNAME/k8s-production-project.git
cd k8s-production-project
```

### Step 2: Start Minikube (3 min)
```bash
minikube start --cpus=4 --memory=8192 --driver=docker
minikube addons enable ingress
minikube addons enable metrics-server
```

### Step 3: Install Security Tools (2 min)
```bash
# Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# OPA Gatekeeper
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
kubectl wait --for=condition=Ready pod -l control-plane=controller-manager -n gatekeeper-system --timeout=300s
```

### Step 4: Verify Setup (1 min)
```bash
kubectl get nodes
kubectl top nodes
kubectl get pods -n gatekeeper-system
trivy --version
```

### Step 5: Ready to Deploy! (3 min)
```bash
# Follow Phase 1 in docs/IMPLEMENTATION-PLAN.md
# Build your first application
```

---

## 📚 What to Read Next

1. **[README.md](README.md)** - Project overview
2. **[docs/RESEARCH.md](docs/RESEARCH.md)** - Understand concepts
3. **[diagrams/ARCHITECTURE.md](diagrams/ARCHITECTURE.md)** - Visual architecture
4. **[docs/IMPLEMENTATION-PLAN.md](docs/IMPLEMENTATION-PLAN.md)** - 7-phase build guide

---

## 🆘 Troubleshooting

### Minikube won't start
```bash
minikube delete
minikube start --cpus=4 --memory=8192 --driver=docker
```

### Addons not enabling
```bash
minikube addons list
# Wait 2-3 minutes after enabling
```

### Insufficient resources
```bash
# Minimum: 4 CPU, 8GB RAM
# Check: docker stats
```

---

## ✅ Success Checklist

- [ ] Minikube running
- [ ] Ingress addon enabled
- [ ] Metrics-server addon enabled
- [ ] Trivy installed
- [ ] OPA Gatekeeper running
- [ ] kubectl working

**All checked? You're ready to build! 🚀**
