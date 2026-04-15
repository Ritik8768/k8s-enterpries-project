from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from datetime import datetime
import os
import psutil

app = FastAPI(title="Production API", version="1.0.0")

# Serve frontend
@app.get("/", response_class=HTMLResponse)
async def frontend():
    try:
        with open("index.html", "r") as f:
            return HTMLResponse(content=f.read())
    except:
        return HTMLResponse(content="<h1>API Running</h1>")

# Health check for liveness probe
@app.get("/health")
def health():
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

# Readiness check
@app.get("/ready")
def ready():
    return {"status": "ready", "timestamp": datetime.now().isoformat()}

# Main API endpoint
@app.get("/api/data")
def get_data():
    return {
        "message": "Hello from Production Kubernetes!",
        "pod": os.getenv("HOSTNAME", "unknown"),
        "timestamp": datetime.now().isoformat()
    }

# Metrics endpoint for monitoring
@app.get("/metrics")
def metrics():
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    return {
        "cpu_percent": cpu_percent,
        "memory_percent": memory.percent,
        "pod": os.getenv("HOSTNAME", "unknown")
    }

# Root endpoint
@app.get("/info")
def root():
    return {
        "app": "Production Kubernetes API",
        "version": "1.0.0",
        "endpoints": ["/health", "/ready", "/api/data", "/metrics"]
    }
