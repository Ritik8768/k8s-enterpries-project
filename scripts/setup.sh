#!/bin/bash

echo "🚀 Setting up Production Kubernetes Environment..."

# Check if minikube is running
if ! minikube status &> /dev/null; then
    echo "📦 Starting Minikube..."
    minikube start --cpus=4 --memory=8192 --driver=docker
else
    echo "✅ Minikube already running"
fi

# Enable addons
echo "🔧 Enabling addons..."
minikube addons enable ingress
minikube addons enable metrics-server

# Wait for addons
echo "⏳ Waiting for addons to be ready..."
sleep 30

# Verify
echo "✅ Verifying setup..."
kubectl get nodes
kubectl top nodes 2>/dev/null || echo "⚠️  Metrics server still initializing (wait 2-3 minutes)"

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Build the Docker image: ./scripts/build.sh"
echo "2. Deploy the application: ./scripts/deploy.sh"
