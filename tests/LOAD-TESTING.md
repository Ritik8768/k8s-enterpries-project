# 🔥 Locust Load Testing Guide

## Quick Start

### Option 1: Web UI (Recommended)

```bash
# Start Locust
./scripts/load-test.sh

# Open browser
http://localhost:8089

# Configure test:
- Number of users: 100
- Spawn rate: 10
- Host: http://api.local (pre-filled)

# Click "Start Swarming"
```

### Option 2: Headless (Command Line)

```bash
cd ~/k8s-production-project

# Run for 5 minutes with 100 users
locust -f tests/locustfile.py \
  --host=http://api.local \
  --users 100 \
  --spawn-rate 10 \
  --run-time 5m \
  --headless
```

---

## Watch Auto-Scaling in Action

**Terminal 1:** Run load test
```bash
./scripts/load-test.sh
```

**Terminal 2:** Watch HPA
```bash
kubectl get hpa -n production-api -w
```

**Terminal 3:** Watch pods
```bash
kubectl get pods -n production-api -w
```

**Terminal 4:** Watch metrics
```bash
watch -n 2 'kubectl top pods -n production-api'
```

---

## Test Scenarios

### Scenario 1: Light Load (Baseline)
```bash
locust -f tests/locustfile.py \
  --host=http://api.local \
  --users 10 \
  --spawn-rate 2 \
  --run-time 2m \
  --headless
```
**Expected:** 2 pods, low CPU

### Scenario 2: Medium Load
```bash
locust -f tests/locustfile.py \
  --host=http://api.local \
  --users 50 \
  --spawn-rate 10 \
  --run-time 5m \
  --headless
```
**Expected:** 3-5 pods, CPU ~70%

### Scenario 3: Heavy Load (Scale Test)
```bash
locust -f tests/locustfile.py \
  --host=http://api.local \
  --users 200 \
  --spawn-rate 20 \
  --run-time 10m \
  --headless
```
**Expected:** 8-10 pods, CPU ~70-80%

### Scenario 4: Spike Test
```bash
locust -f tests/locustfile.py \
  --host=http://api.local \
  --users 300 \
  --spawn-rate 50 \
  --run-time 3m \
  --headless
```
**Expected:** Rapid scale to max (10 pods)

---

## Understanding Results

### Locust Metrics

**RPS (Requests Per Second)**
- Good: >100 RPS with 2 pods
- Excellent: >500 RPS with 10 pods

**Response Time**
- Good: <200ms (p95)
- Excellent: <100ms (p95)

**Failure Rate**
- Target: 0%
- Acceptable: <1%

### HPA Behavior

**Scale Up:**
- Triggers when CPU >70%
- Immediate (no delay)
- Adds pods gradually

**Scale Down:**
- Triggers when CPU <70%
- 5 minute cooldown
- Removes pods gradually

---

## Example Output

### Locust Web UI
```
Type     Name              # reqs    # fails   Avg    Min    Max    Median  req/s
GET      /api/data         15000     0         45ms   12ms   234ms  38ms    250.0
GET      /health           10000     0         23ms   8ms    156ms  19ms    166.7
GET      /ready            10000     0         24ms   9ms    167ms  20ms    166.7
GET      /metrics          5000      0         67ms   15ms   345ms  54ms    83.3
GET      /                 5000      0         89ms   23ms   456ms  76ms    83.3

Total                      45000     0         42ms   8ms    456ms  35ms    750.0
```

### HPA Scaling
```
NAME      REFERENCE                   TARGETS    MINPODS   MAXPODS   REPLICAS
api-hpa   Deployment/api-deployment   15%/70%    2         10        2
api-hpa   Deployment/api-deployment   45%/70%    2         10        2
api-hpa   Deployment/api-deployment   78%/70%    2         10        2
api-hpa   Deployment/api-deployment   82%/70%    2         10        3
api-hpa   Deployment/api-deployment   75%/70%    2         10        4
api-hpa   Deployment/api-deployment   71%/70%    2         10        5
api-hpa   Deployment/api-deployment   68%/70%    2         10        5
```

---

## Tips

1. **Start Small:** Begin with 10 users, increase gradually
2. **Watch Metrics:** Monitor HPA and pod metrics during test
3. **Wait for Stabilization:** Give HPA 2-3 minutes to react
4. **Test Scale Down:** Stop load and watch pods scale down (5 min)
5. **Check Logs:** Look for errors during high load

---

## Troubleshooting

### Connection Refused
```bash
# Check if api.local resolves
ping api.local

# Check ingress
kubectl get ingress -n production-api
```

### No Scaling
```bash
# Check HPA
kubectl describe hpa api-hpa -n production-api

# Check metrics
kubectl top pods -n production-api

# Wait 2-3 minutes for metrics to populate
```

### High Failure Rate
```bash
# Check pod logs
kubectl logs -n production-api -l app=api --tail=50

# Check resource limits
kubectl describe pod -n production-api <pod-name>
```

---

## Advanced: Custom Test

Create your own test in `tests/locustfile.py`:

```python
from locust import HttpUser, task, between

class CustomUser(HttpUser):
    wait_time = between(1, 2)
    host = "http://api.local"
    
    @task
    def my_custom_test(self):
        # Your custom logic
        response = self.client.get("/api/data")
        if response.status_code == 200:
            print(f"Success: {response.json()}")
```

---

## Clean Up

```bash
# Stop Locust: Ctrl+C

# Scale down manually if needed
kubectl scale deployment api-deployment -n production-api --replicas=2
```

---

**Happy Load Testing!** 🔥
