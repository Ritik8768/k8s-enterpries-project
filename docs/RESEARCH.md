# Production Kubernetes System - Research & Implementation Guide

## 📋 Project Overview

**Project Name**: Secure Auto-Scaling API Platform on Kubernetes

**Problem Statement**: 
Most applications fail in production due to lack of self-healing, poor scaling, security vulnerabilities, and insecure configurations. This project demonstrates enterprise-grade Kubernetes deployment practices.

**Real-World Use Case**: 
E-commerce API that handles variable traffic (Black Friday spikes), must stay available 24/7, and comply with security standards (PCI-DSS, SOC2).

---

## 🎯 Project Scope

### In-Scope
✅ Simple REST API application (Python FastAPI)
✅ Self-healing with Kubernetes probes
✅ Horizontal Pod Autoscaling (HPA)
✅ Ingress routing with NGINX
✅ Container image vulnerability scanning (Trivy)
✅ Policy enforcement with OPA Gatekeeper
✅ Resource management (limits/requests)
✅ Monitoring and metrics
✅ Security best practices

### Out-of-Scope
❌ Multi-cluster deployment
❌ Service mesh (Istio/Linkerd)
❌ GitOps (ArgoCD/Flux)
❌ Advanced monitoring (Prometheus/Grafana)
❌ CI/CD pipeline integration
❌ Database persistence (focus on stateless API)

---

## 🔬 Deep Research & Concepts

### 1. Self-Healing with Probes

**What is it?**
Kubernetes automatically detects and recovers from failures without manual intervention.

**Three Types of Probes:**

#### a) Liveness Probe
- **Purpose**: Detect if container is alive
- **Action**: Restart container if fails
- **Use Case**: Deadlocked application, infinite loop
- **Example**: HTTP GET /health returns 200

#### b) Readiness Probe
- **Purpose**: Detect if container can serve traffic
- **Action**: Remove from service endpoints if fails
- **Use Case**: Warming up, loading data, temporary unavailability
- **Example**: HTTP GET /ready returns 200

#### c) Startup Probe
- **Purpose**: Handle slow-starting containers
- **Action**: Disable liveness/readiness until passes
- **Use Case**: Legacy apps with long initialization
- **Example**: 30 attempts × 10s = 5 min startup time

**Probe Methods:**
- HTTP GET (most common for APIs)
- TCP Socket (for non-HTTP services)
- Exec Command (run command inside container)

**Best Practices:**
- Liveness: Check critical dependencies only
- Readiness: Check all dependencies
- Use different endpoints for each probe
- Set appropriate timeouts (avoid false positives)
- Initial delay > app startup time

---

### 2. Horizontal Pod Autoscaling (HPA)

**What is it?**
Automatically scales number of pods based on observed metrics.

**How it Works:**
```
Current Metric Value
─────────────────── × Current Replicas = Desired Replicas
Target Metric Value
```

**Metrics Types:**

#### a) Resource Metrics (CPU/Memory)
- Built-in, requires metrics-server
- CPU: Based on requests (not limits)
- Memory: Less common (can cause thrashing)

#### b) Custom Metrics
- Application-specific (requests/sec, queue length)
- Requires custom metrics adapter

#### c) External Metrics
- From external systems (AWS CloudWatch, Datadog)

**HPA Algorithm:**
1. Fetch metrics every 15s (default)
2. Calculate desired replicas
3. Scale up immediately if needed
4. Scale down gradually (5 min cooldown)

**Best Practices:**
- Set realistic min/max replicas
- Use CPU target: 70-80% (not 100%)
- Combine with Cluster Autoscaler for nodes
- Test with load testing tools
- Monitor scaling events

**Common Issues:**
- Insufficient resources → pods pending
- Too aggressive scaling → cost increase
- Metrics delay → slow response

---

### 3. Ingress Routing

**What is it?**
Exposes HTTP/HTTPS routes from outside cluster to services inside.

**Why Not LoadBalancer Service?**
- LoadBalancer = 1 external IP per service (expensive)
- Ingress = 1 external IP for many services (cost-effective)

**Components:**

#### a) Ingress Controller
- NGINX (most popular)
- Traefik (modern, easy)
- HAProxy, Contour, etc.

#### b) Ingress Resource
- Defines routing rules
- Path-based: /api → api-service
- Host-based: api.example.com → api-service

**Features:**
- TLS/SSL termination
- Path rewriting
- Rate limiting
- Authentication
- Load balancing

**NGINX Ingress Annotations:**
```yaml
nginx.ingress.kubernetes.io/rewrite-target: /
nginx.ingress.kubernetes.io/rate-limit: "100"
nginx.ingress.kubernetes.io/ssl-redirect: "true"
```

**Best Practices:**
- Use TLS for production
- Implement rate limiting
- Configure timeouts properly
- Use path prefixes consistently
- Monitor ingress metrics

---

### 4. Image Scanning with Trivy

**What is it?**
Detects vulnerabilities (CVEs) in container images before deployment.

**How Trivy Works:**
1. Downloads vulnerability database
2. Scans image layers
3. Identifies packages and versions
4. Matches against CVE database
5. Reports severity (Critical, High, Medium, Low)

**Scan Types:**
- **Image**: Container images
- **Filesystem**: Local directories
- **Repository**: Git repos
- **Config**: IaC files (Dockerfile, K8s YAML)

**Vulnerability Severity:**
- **Critical**: Immediate fix required (CVSS 9.0-10.0)
- **High**: Fix ASAP (CVSS 7.0-8.9)
- **Medium**: Fix soon (CVSS 4.0-6.9)
- **Low**: Fix when possible (CVSS 0.1-3.9)

**Integration Points:**
- CI/CD pipeline (block builds)
- Pre-deployment (scan before kubectl apply)
- Registry scanning (scan on push)
- Scheduled scans (daily/weekly)

**Best Practices:**
- Use minimal base images (distroless, alpine)
- Scan in CI/CD pipeline
- Set severity threshold (block Critical/High)
- Keep base images updated
- Use multi-stage builds

**Alternative: Docker Scout**
- Built into Docker Desktop
- Similar functionality
- Better Docker integration

---

### 5. OPA Gatekeeper (Policy Enforcement)

**What is it?**
Admission controller that enforces custom policies on Kubernetes resources.

**How it Works:**
```
kubectl apply → API Server → OPA Gatekeeper → Validate → Allow/Deny
```

**Architecture:**

#### a) Constraint Templates
- Define policy logic (Rego language)
- Reusable across constraints
- Example: "Require labels" template

#### b) Constraints
- Instance of template with parameters
- Example: "Require 'owner' label"

**Common Policies:**

1. **Security Policies**
   - Block privileged containers
   - Require non-root user
   - Block hostPath volumes
   - Require read-only root filesystem

2. **Resource Policies**
   - Require resource limits/requests
   - Enforce minimum/maximum resources
   - Block resource-hungry pods

3. **Image Policies**
   - Block 'latest' tag
   - Require approved registries
   - Require image scanning labels

4. **Compliance Policies**
   - Require specific labels
   - Enforce naming conventions
   - Require annotations

**Rego Language Basics:**
```rego
package k8srequiredlabels

violation[{"msg": msg}] {
  not input.review.object.metadata.labels.owner
  msg := "Missing required label: owner"
}
```

**Best Practices:**
- Start with audit mode (warn, don't block)
- Test policies in dev first
- Document policy requirements
- Provide clear error messages
- Monitor policy violations

**Dry Run Testing:**
```bash
kubectl apply --dry-run=server -f deployment.yaml
```

---

## 📊 Technology Stack Research

### Application Options

#### Option 1: Python Flask
**Pros**: Simple, beginner-friendly, fast development
**Cons**: Not async by default
**Use Case**: Simple REST APIs

#### Option 2: Python FastAPI
**Pros**: Modern, async, auto-documentation, type hints
**Cons**: Slightly more complex
**Use Case**: High-performance APIs

#### Option 3: Node.js Express
**Pros**: Async, large ecosystem, JavaScript
**Cons**: Callback hell (if not using async/await)
**Use Case**: Real-time applications

**Recommendation**: FastAPI (modern, production-ready, great docs)

---

### Base Image Options

| Image | Size | Security | Use Case |
|-------|------|----------|----------|
| python:3.11 | 1GB | Medium | Development |
| python:3.11-slim | 150MB | Good | General use |
| python:3.11-alpine | 50MB | Good | Size-critical |
| distroless/python3 | 60MB | Excellent | Production |

**Recommendation**: python:3.11-slim (balance of size and compatibility)

---

### Minikube Resource Requirements

**Minimum:**
- CPU: 2 cores
- Memory: 4GB
- Disk: 20GB

**Recommended for this project:**
- CPU: 4 cores
- Memory: 8GB
- Disk: 30GB

**Why?**
- Ingress controller: ~500MB
- Metrics server: ~100MB
- OPA Gatekeeper: ~200MB
- Application pods: ~100MB each
- Overhead: ~1GB

---

## 🎯 Success Criteria

### Technical Metrics
✅ API responds within 200ms (p95)
✅ 99.9% uptime (self-healing works)
✅ Scales from 2 to 10 pods under load
✅ Zero critical/high vulnerabilities
✅ 100% policy compliance
✅ Zero-downtime deployments

### Learning Metrics
✅ Understand all Kubernetes concepts used
✅ Can explain each component's purpose
✅ Can troubleshoot common issues
✅ Can modify and extend the system
✅ Can apply to real-world projects

---

## 🚀 Quick Start Commands

```bash
# Setup Minikube
minikube start --cpus=4 --memory=8192
minikube addons enable ingress
minikube addons enable metrics-server

# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Install OPA Gatekeeper
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml

# Access application
minikube tunnel  # Run in separate terminal
```

---

## 📚 Additional Resources

### Documentation
- Kubernetes Docs: https://kubernetes.io/docs
- Trivy Docs: https://aquasecurity.github.io/trivy
- OPA Gatekeeper: https://open-policy-agent.github.io/gatekeeper
- NGINX Ingress: https://kubernetes.github.io/ingress-nginx

### Tools
- k9s: Terminal UI for Kubernetes
- kubectx/kubens: Context and namespace switching
- stern: Multi-pod log tailing
- hey/ab: Load testing tools

### Communities
- Kubernetes Slack: kubernetes.slack.com
- Reddit: r/kubernetes
- Stack Overflow: kubernetes tag
