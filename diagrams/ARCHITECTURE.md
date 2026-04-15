# System Architecture Diagrams

## 1. High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         EXTERNAL USERS                          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTPS
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      MINIKUBE CLUSTER                           │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              NGINX INGRESS CONTROLLER                     │ │
│  │  - TLS Termination                                        │ │
│  │  - Rate Limiting                                          │ │
│  │  - Path-based Routing                                     │ │
│  └─────────────────────┬─────────────────────────────────────┘ │
│                        │                                        │
│                        │ /api/*                                 │
│                        ▼                                        │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                  API SERVICE (ClusterIP)                  │ │
│  │  - Load Balancing                                         │ │
│  │  - Service Discovery                                      │ │
│  └─────────────────────┬─────────────────────────────────────┘ │
│                        │                                        │
│                        │ Round Robin                            │
│                        ▼                                        │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                  API DEPLOYMENT                           │ │
│  │                                                           │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │ │
│  │  │  Pod 1   │  │  Pod 2   │  │  Pod 3   │  │  Pod N   │ │ │
│  │  │          │  │          │  │          │  │          │ │ │
│  │  │ ┌──────┐ │  │ ┌──────┐ │  │ ┌──────┐ │  │ ┌──────┐ │ │ │
│  │  │ │ API  │ │  │ │ API  │ │  │ │ API  │ │  │ │ API  │ │ │ │
│  │  │ │ App  │ │  │ │ App  │ │  │ │ App  │ │  │ │ App  │ │ │ │
│  │  │ └──────┘ │  │ └──────┘ │  │ └──────┘ │  │ └──────┘ │ │ │
│  │  │          │  │          │  │          │  │          │ │ │
│  │  │ Probes:  │  │ Probes:  │  │ Probes:  │  │ Probes:  │ │ │
│  │  │ ✓ Live   │  │ ✓ Live   │  │ ✓ Live   │  │ ✓ Live   │ │ │
│  │  │ ✓ Ready  │  │ ✓ Ready  │  │ ✓ Ready  │  │ ✓ Ready  │ │ │
│  │  │ ✓ Startup│  │ ✓ Startup│  │ ✓ Startup│  │ ✓ Startup│ │ │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘ │ │
│  │                                                           │ │
│  │  Min: 2 Replicas  ◄──────────────────►  Max: 10 Replicas│ │
│  └───────────────────────────────────────────────────────────┘ │
│                        ▲                                        │
│                        │                                        │
│                        │ Metrics                                │
│  ┌─────────────────────┴─────────────────────────────────────┐ │
│  │         HORIZONTAL POD AUTOSCALER (HPA)                   │ │
│  │  - Target: 70% CPU                                        │ │
│  │  - Scale Up: Immediate                                    │ │
│  │  - Scale Down: 5 min cooldown                            │ │
│  └─────────────────────┬─────────────────────────────────────┘ │
│                        │                                        │
│                        │ CPU/Memory Metrics                     │
│                        ▼                                        │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              METRICS SERVER                               │ │
│  │  - Collects resource metrics                             │ │
│  │  - 15s scrape interval                                   │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Security Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS                              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  LAYER 1: PRE-DEPLOYMENT SECURITY                               │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  TRIVY IMAGE SCANNER                                     │  │
│  │                                                          │  │
│  │  Docker Image  ──►  Scan  ──►  Vulnerability Report    │  │
│  │                                                          │  │
│  │  ✓ Check CVE Database                                   │  │
│  │  ✓ Identify Critical/High Issues                        │  │
│  │  ✓ Block Deployment if Threshold Exceeded               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                             │
                             │ Image Approved
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  LAYER 2: ADMISSION CONTROL                                     │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  OPA GATEKEEPER                                          │  │
│  │                                                          │  │
│  │  kubectl apply ──► API Server ──► Gatekeeper ──► Allow  │  │
│  │                                         │                │  │
│  │                                         └──► Deny        │  │
│  │                                                          │  │
│  │  POLICIES ENFORCED:                                      │  │
│  │  ✓ No privileged containers                             │  │
│  │  ✓ Must have resource limits                            │  │
│  │  ✓ No 'latest' image tags                               │  │
│  │  ✓ Must run as non-root                                 │  │
│  │  ✓ Read-only root filesystem                            │  │
│  │  ✓ Required labels present                              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                             │
                             │ Policy Compliant
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  LAYER 3: RUNTIME SECURITY                                      │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  POD SECURITY                                            │  │
│  │                                                          │  │
│  │  ✓ Security Context Applied                             │  │
│  │  ✓ Non-root User (UID 1000)                             │  │
│  │  ✓ Read-only Root Filesystem                            │  │
│  │  ✓ Drop All Capabilities                                │  │
│  │  ✓ No Privilege Escalation                              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Self-Healing Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    SELF-HEALING MECHANISM                       │
└─────────────────────────────────────────────────────────────────┘

SCENARIO 1: Application Crash
─────────────────────────────

  Pod Running
      │
      │ Application crashes
      ▼
  ┌─────────────────┐
  │ Liveness Probe  │
  │ Fails (3 times) │
  └────────┬────────┘
           │
           │ Restart Policy: Always
           ▼
  ┌─────────────────┐
  │ Kubelet Restarts│
  │   Container     │
  └────────┬────────┘
           │
           ▼
  Pod Running Again
  (Self-Healed)


SCENARIO 2: Temporary Unavailability
────────────────────────────────────

  Pod Running & Serving Traffic
      │
      │ Database connection lost
      ▼
  ┌─────────────────┐
  │ Readiness Probe │
  │ Fails           │
  └────────┬────────┘
           │
           │ Remove from Service
           ▼
  ┌─────────────────┐
  │ Pod NOT in      │
  │ Service Endpoints│
  └────────┬────────┘
           │
           │ No traffic sent to pod
           │
           │ Connection restored
           ▼
  ┌─────────────────┐
  │ Readiness Probe │
  │ Passes          │
  └────────┬────────┘
           │
           │ Add back to Service
           ▼
  Pod Serving Traffic Again
  (Self-Healed)


SCENARIO 3: Slow Startup
─────────────────────────

  Pod Starting
      │
      │ Loading large dataset
      ▼
  ┌─────────────────┐
  │ Startup Probe   │
  │ Checking...     │
  └────────┬────────┘
           │
           │ Liveness/Readiness disabled
           │ (Prevents premature restart)
           │
           │ Startup complete
           ▼
  ┌─────────────────┐
  │ Startup Probe   │
  │ Passes          │
  └────────┬────────┘
           │
           │ Enable other probes
           ▼
  Pod Ready to Serve
```

---

## 4. Auto-Scaling Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    AUTO-SCALING PROCESS                         │
└─────────────────────────────────────────────────────────────────┘

NORMAL LOAD (2 Pods)
────────────────────

  ┌──────┐  ┌──────┐
  │ Pod1 │  │ Pod2 │
  │ 30%  │  │ 35%  │  ◄── CPU Usage
  └──────┘  └──────┘

  Average CPU: 32.5%
  Target: 70%
  Action: No scaling needed


INCREASING LOAD
───────────────

  Traffic Increases ──► CPU Usage Rises
                              │
                              ▼
  ┌──────┐  ┌──────┐
  │ Pod1 │  │ Pod2 │
  │ 85%  │  │ 90%  │  ◄── CPU Usage
  └──────┘  └──────┘

  Average CPU: 87.5%
  Target: 70%
  
  Calculation:
  Desired = (87.5 / 70) × 2 = 2.5 → 3 pods
  
  Action: Scale UP immediately


SCALING UP
──────────

  ┌──────┐  ┌──────┐  ┌──────┐
  │ Pod1 │  │ Pod2 │  │ Pod3 │
  │ 60%  │  │ 58%  │  │ 55%  │  ◄── CPU Usage
  └──────┘  └──────┘  └──────┘

  Average CPU: 57.6%
  Target: 70%
  Action: Stable


LOAD DECREASES
──────────────

  Traffic Decreases ──► CPU Usage Drops
                              │
                              ▼
  ┌──────┐  ┌──────┐  ┌──────┐
  │ Pod1 │  │ Pod2 │  │ Pod3 │
  │ 20%  │  │ 25%  │  │ 22%  │  ◄── CPU Usage
  └──────┘  └──────┘  └──────┘

  Average CPU: 22.3%
  Target: 70%
  
  Calculation:
  Desired = (22.3 / 70) × 3 = 0.95 → 2 pods
  
  Action: Wait 5 minutes (cooldown)
          Then scale DOWN


SCALED DOWN
───────────

  ┌──────┐  ┌──────┐
  │ Pod1 │  │ Pod2 │
  │ 35%  │  │ 32%  │  ◄── CPU Usage
  └──────┘  └──────┘

  Average CPU: 33.5%
  Target: 70%
  Action: Stable at minimum replicas
```

---

## 5. Request Flow with Ingress

```
┌─────────────────────────────────────────────────────────────────┐
│                    REQUEST FLOW DIAGRAM                         │
└─────────────────────────────────────────────────────────────────┘

1. External Request
   │
   │ curl http://api.local/api/data
   │
   ▼
┌──────────────────────────────────────┐
│  INGRESS CONTROLLER (NGINX)          │
│                                      │
│  ┌────────────────────────────────┐ │
│  │ Routing Rules:                 │ │
│  │ - Host: api.local              │ │
│  │ - Path: /api/*                 │ │
│  │ - Backend: api-service:8000    │ │
│  └────────────────────────────────┘ │
│                                      │
│  ┌────────────────────────────────┐ │
│  │ Features Applied:              │ │
│  │ ✓ Rate Limiting (100 req/min) │ │
│  │ ✓ TLS Termination             │ │
│  │ ✓ Request Logging             │ │
│  └────────────────────────────────┘ │
└──────────────┬───────────────────────┘
               │
               │ Forward to Service
               ▼
┌──────────────────────────────────────┐
│  SERVICE (api-service)               │
│  Type: ClusterIP                     │
│  Port: 8000                          │
│                                      │
│  Endpoints (Healthy Pods):           │
│  - 10.244.0.5:8000 (Pod1) ✓         │
│  - 10.244.0.6:8000 (Pod2) ✓         │
│  - 10.244.0.7:8000 (Pod3) ✓         │
└──────────────┬───────────────────────┘
               │
               │ Load Balance (Round Robin)
               ▼
┌──────────────────────────────────────┐
│  POD (Selected by Service)           │
│                                      │
│  ┌────────────────────────────────┐ │
│  │ Container: api-app             │ │
│  │ Port: 8000                     │ │
│  │                                │ │
│  │ Health Checks:                 │ │
│  │ ✓ Liveness: /health            │ │
│  │ ✓ Readiness: /ready            │ │
│  └────────────────────────────────┘ │
│                                      │
│  Process Request ──► Generate Response│
└──────────────┬───────────────────────┘
               │
               │ Response
               ▼
         Return to Client

Response Path:
Pod ──► Service ──► Ingress ──► Client
```

---

## 6. Component Interaction Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│              KUBERNETES CONTROL PLANE                           │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ API Server   │  │  Scheduler   │  │  Controller  │         │
│  │              │  │              │  │   Manager    │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                 │                 │                  │
└─────────┼─────────────────┼─────────────────┼──────────────────┘
          │                 │                 │
          │                 │                 │
┌─────────┼─────────────────┼─────────────────┼──────────────────┐
│         │                 │                 │                  │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐         │
│  │   Kubelet    │  │   Kubelet    │  │   Kubelet    │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                 │                 │                  │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐         │
│  │   Pod 1      │  │   Pod 2      │  │   Pod 3      │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                 │
│  NODE (Minikube)                                               │
└─────────────────────────────────────────────────────────────────┘
          ▲                                      ▲
          │                                      │
          │                                      │
  ┌───────┴────────┐                    ┌────────┴────────┐
  │ Metrics Server │                    │ OPA Gatekeeper  │
  │ (Monitoring)   │                    │ (Admission)     │
  └────────────────┘                    └─────────────────┘
```

---

## 7. Deployment Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEPLOYMENT PIPELINE                          │
└─────────────────────────────────────────────────────────────────┘

STEP 1: Build
─────────────
  ┌──────────────┐
  │ Source Code  │
  │ (app.py)     │
  └──────┬───────┘
         │
         │ docker build
         ▼
  ┌──────────────┐
  │ Docker Image │
  │ api-app:v1.0 │
  └──────┬───────┘
         │
         ▼

STEP 2: Security Scan
─────────────────────
  ┌──────────────┐
  │ Trivy Scan   │
  │              │
  │ Scanning...  │
  └──────┬───────┘
         │
         ├──► Critical/High CVEs? ──► BLOCK ──► Fix & Rebuild
         │
         └──► Clean ──► Continue
                        │
                        ▼

STEP 3: Push Image
──────────────────
  ┌──────────────┐
  │ Push to      │
  │ Registry     │
  └──────┬───────┘
         │
         ▼

STEP 4: Policy Check
────────────────────
  ┌──────────────┐
  │ kubectl apply│
  │ --dry-run    │
  └──────┬───────┘
         │
         │ OPA Gatekeeper validates
         │
         ├──► Policy Violation? ──► BLOCK ──► Fix YAML
         │
         └──► Compliant ──► Continue
                           │
                           ▼

STEP 5: Deploy
──────────────
  ┌──────────────┐
  │ kubectl apply│
  │ -f deploy.yml│
  └──────┬───────┘
         │
         │ Rolling Update
         ▼
  ┌──────────────┐
  │ Pods Created │
  │              │
  │ ✓ Startup    │
  │ ✓ Readiness  │
  │ ✓ Liveness   │
  └──────┬───────┘
         │
         ▼
  ┌──────────────┐
  │ Deployment   │
  │ SUCCESS      │
  └──────────────┘
```

---

## 8. Monitoring & Observability

```
┌─────────────────────────────────────────────────────────────────┐
│                    OBSERVABILITY STACK                          │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────┐
│  APPLICATION PODS                    │
│                                      │
│  ┌────────────────────────────────┐ │
│  │ Metrics Exposed:               │ │
│  │ - CPU Usage                    │ │
│  │ - Memory Usage                 │ │
│  │ - Request Count                │ │
│  │ - Response Time                │ │
│  │ - Error Rate                   │ │
│  └────────────┬───────────────────┘ │
└───────────────┼──────────────────────┘
                │
                │ Scrape Metrics
                ▼
┌──────────────────────────────────────┐
│  METRICS SERVER                      │
│  - Collects resource metrics         │
│  - Stores short-term (15 min)        │
│  - Provides to HPA                   │
└────────────┬─────────────────────────┘
             │
             │ Metrics API
             ▼
┌──────────────────────────────────────┐
│  HORIZONTAL POD AUTOSCALER           │
│  - Queries metrics every 15s         │
│  - Calculates desired replicas       │
│  - Triggers scaling                  │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  KUBECTL COMMANDS                    │
│                                      │
│  kubectl top pods                    │
│  kubectl top nodes                   │
│  kubectl get hpa                     │
│  kubectl describe pod <name>         │
│  kubectl logs <pod>                  │
└──────────────────────────────────────┘
```

This completes the architecture diagrams!
