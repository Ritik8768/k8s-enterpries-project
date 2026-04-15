# Production-Grade Kubernetes System on Minikube

## 🚀 Project Overview

A complete production-grade Kubernetes deployment demonstrating enterprise best practices including self-healing, auto-scaling, security scanning, and policy enforcement.

**Problem Solved**: Most applications fail in production due to lack of resilience, poor scaling, and security vulnerabilities. This project implements all critical production patterns.

---

## ✨ Features

### 1. Self-Healing
- ✅ Liveness probes for automatic restart
- ✅ Readiness probes for traffic management
- ✅ Startup probes for slow-starting apps
- ✅ Automatic recovery from failures

### 2. Auto-Scaling
- ✅ Horizontal Pod Autoscaler (HPA)
- ✅ CPU-based scaling (70% target)
- ✅ Scale 2-10 replicas dynamically
- ✅ Metrics-driven decisions

### 3. Ingress Routing
- ✅ NGINX Ingress Controller
- ✅ Path-based routing
- ✅ Rate limiting
- ✅ External access

### 4. Security Scanning
- ✅ Trivy vulnerability scanning
- ✅ Pre-deployment checks
- ✅ CVE detection
- ✅ Automated remediation

### 5. Policy Enforcement
- ✅ OPA Gatekeeper admission control
- ✅ Security policies
- ✅ Resource policies
- ✅ Compliance enforcement

---

## 🏗️ Architecture

```
External Users
      ↓
NGINX Ingress (TLS, Rate Limiting)
      ↓
Service (Load Balancing)
      ↓
Pods (2-10 replicas with probes)
      ↑
HPA (Auto-scaling based on CPU)
      ↑
Metrics Server
```

**See detailed diagrams**: [diagrams/ARCHITECTURE.md](diagrams/ARCHITECTURE.md)

---

## 📋 Prerequisites

### Required
- Docker (20.10+)
- kubectl (1.25+)
- Minikube (1.30+)
- 4 CPU cores
- 8GB RAM
- 30GB disk space

### Optional
- k9s (Kubernetes TUI)
- hey (Load testing)
- stern (Log tailing)

---

## 🚀 Quick Start

### 1. Setup Minikube
```bash
# Start cluster
minikube start --cpus=4 --memory=8192 --driver=docker

# Enable addons
minikube addons enable ingress
minikube addons enable metrics-server

# Verify
kubectl cluster-info
kubectl get nodes
```

### 2. Install Security Tools
```bash
# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Install OPA Gatekeeper
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml

# Wait for Gatekeeper
kubectl wait --for=condition=Ready pod -l control-plane=controller-manager -n gatekeeper-system --timeout=300s
```

### 3. Deploy Application
```bash
# Coming in Phase 1 implementation
# Will include all manifests
```

### 4. Access Application
```bash
# Start tunnel (separate terminal)
minikube tunnel

# Add to /etc/hosts
echo "$(minikube ip) api.local" | sudo tee -a /etc/hosts

# Test
curl http://api.local/api/data
```

---

## 📁 Project Structure

```
k8s-production-project/
├── README.md                          # This file
├── docs/
│   ├── RESEARCH.md                    # Deep dive into concepts
│   └── IMPLEMENTATION-PLAN.md         # Phase-wise guide
├── diagrams/
│   └── ARCHITECTURE.md                # Visual diagrams
├── app/                               # Application code (Phase 1)
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── k8s/                               # Kubernetes manifests
│   ├── 01-namespace.yaml
│   ├── 02-deployment.yaml
│   ├── 03-service.yaml
│   ├── 04-hpa.yaml
│   ├── 05-ingress.yaml
│   └── security/
│       ├── constraint-templates/
│       └── constraints/
├── scripts/                           # Automation scripts
│   ├── setup.sh
│   ├── scan-image.sh
│   ├── deploy.sh
│   └── test.sh
└── tests/                             # Test scenarios
    ├── load-test.sh
    └── failure-scenarios.sh
```

---

## 📚 Documentation

### For Beginners
1. **[Research Document](docs/RESEARCH.md)** - Understand all concepts in depth
2. **[Implementation Plan](docs/IMPLEMENTATION-PLAN.md)** - Step-by-step guide (7 phases)
3. **[Architecture Diagrams](diagrams/ARCHITECTURE.md)** - Visual understanding

### For Advanced Users
- Jump to specific phases
- Customize configurations
- Extend with additional features

---

## 🎯 Implementation Phases

### Phase 1: Foundation (Week 1)
- Setup environment
- Create API application
- Containerize
- Deploy to Kubernetes

### Phase 2: Self-Healing (Week 2)
- Add health endpoints
- Configure probes
- Test failure scenarios

### Phase 3: Scaling (Week 3)
- Enable metrics
- Configure HPA
- Load testing

### Phase 4: Ingress (Week 4)
- Setup ingress controller
- Configure routing
- External access

### Phase 5: Security - Scanning (Week 5)
- Install Trivy
- Scan images
- Fix vulnerabilities

### Phase 6: Security - Policies (Week 6)
- Install OPA Gatekeeper
- Create policies
- Enforce compliance

### Phase 7: Integration (Week 7)
- End-to-end testing
- Performance tuning
- Documentation

**Detailed guide**: [docs/IMPLEMENTATION-PLAN.md](docs/IMPLEMENTATION-PLAN.md)

---

## 🧪 Testing

### Self-Healing Test
```bash
# Kill pod
kubectl delete pod <pod-name>

# Watch recovery
kubectl get pods -w
```

### Auto-Scaling Test
```bash
# Generate load
hey -z 5m -c 100 http://api.local/api/data

# Watch scaling
kubectl get hpa -w
```

### Security Test
```bash
# Scan image
trivy image --severity HIGH,CRITICAL api-app:v1.0

# Test policy violation
kubectl apply -f bad-deployment.yaml  # Should be blocked
```

---

## 📊 Monitoring

### Check Pod Status
```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Check Metrics
```bash
kubectl top nodes
kubectl top pods
```

### Check HPA
```bash
kubectl get hpa
kubectl describe hpa api-hpa
```

### Check Ingress
```bash
kubectl get ingress
kubectl describe ingress api-ingress
```

### Check Policies
```bash
kubectl get constraints
kubectl get constrainttemplates
```

---

## 🔧 Troubleshooting

### Pod Not Starting
```bash
# Check events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Check previous logs (if crashed)
kubectl logs <pod-name> --previous
```

### HPA Not Scaling
```bash
# Check metrics server
kubectl top pods

# Check HPA status
kubectl describe hpa api-hpa

# Check resource requests (must be set)
kubectl get pod <pod-name> -o yaml | grep -A 5 resources
```

### Ingress Not Working
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Check ingress resource
kubectl describe ingress api-ingress

# Check service endpoints
kubectl get endpoints
```

### Policy Blocking Deployment
```bash
# Check constraint violations
kubectl get constraints

# Dry run to see errors
kubectl apply --dry-run=server -f deployment.yaml
```

---

## 🎓 Learning Outcomes

After completing this project, you will understand:

### Kubernetes Concepts
- Pods, Deployments, Services
- ConfigMaps, Secrets
- Resource management
- Namespaces

### Production Patterns
- Self-healing mechanisms
- Horizontal scaling
- Health checks
- Rolling updates

### Security
- Container scanning
- Policy enforcement
- Admission control
- Security contexts

### Networking
- Services and endpoints
- Ingress routing
- Load balancing
- DNS

### Operations
- Monitoring and metrics
- Troubleshooting
- Performance tuning
- Best practices

---

## 🌟 Real-World Applications

This architecture is used by:
- E-commerce platforms (handle traffic spikes)
- SaaS applications (multi-tenant isolation)
- Financial services (security compliance)
- Healthcare systems (high availability)
- Media streaming (auto-scaling)

---

## 📈 Success Metrics

### Technical
- ✅ 99.9% uptime
- ✅ <200ms response time (p95)
- ✅ Auto-scale 2-10 pods
- ✅ Zero critical vulnerabilities
- ✅ 100% policy compliance

### Learning
- ✅ Understand all components
- ✅ Can troubleshoot issues
- ✅ Can extend the system
- ✅ Can apply to real projects

---

## 🤝 Contributing

This is a learning project. Feel free to:
- Add more features
- Improve documentation
- Share your learnings
- Create tutorials

---

## 📝 License

MIT License - Feel free to use for learning and projects

---

## 🔗 Resources

### Official Documentation
- [Kubernetes](https://kubernetes.io/docs)
- [Minikube](https://minikube.sigs.k8s.io/docs)
- [Trivy](https://aquasecurity.github.io/trivy)
- [OPA Gatekeeper](https://open-policy-agent.github.io/gatekeeper)

### Tools
- [k9s](https://k9scli.io) - Kubernetes TUI
- [hey](https://github.com/rakyll/hey) - Load testing
- [stern](https://github.com/stern/stern) - Log tailing

### Communities
- Kubernetes Slack
- Reddit r/kubernetes
- Stack Overflow

---

## 🎬 Next Steps

1. ✅ Read [RESEARCH.md](docs/RESEARCH.md) to understand concepts
2. ✅ Review [ARCHITECTURE.md](diagrams/ARCHITECTURE.md) for visual understanding
3. ✅ Follow [IMPLEMENTATION-PLAN.md](docs/IMPLEMENTATION-PLAN.md) phase by phase
4. ✅ Build, test, and learn!

---

## 📧 Questions?

- Check documentation first
- Review troubleshooting section
- Search Kubernetes docs
- Ask in communities

---

**Ready to build production-grade Kubernetes systems? Let's start with Phase 1!** 🚀
