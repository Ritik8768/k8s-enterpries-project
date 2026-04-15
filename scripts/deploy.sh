#!/bin/bash

echo "🚀 Deploying Production Kubernetes Application..."

# Apply namespace
echo "📦 Creating namespace..."
kubectl apply -f k8s/01-namespace.yaml

# Apply deployment
echo "🔧 Deploying application..."
kubectl apply -f k8s/02-deployment.yaml

# Apply service
echo "🌐 Creating service..."
kubectl apply -f k8s/03-service.yaml

# Apply HPA
echo "📊 Configuring autoscaling..."
kubectl apply -f k8s/04-hpa.yaml

# Apply ingress
echo "🔌 Setting up ingress..."
kubectl apply -f k8s/05-ingress.yaml

# Wait for pods
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=api -n production-api --timeout=120s

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Status:"
kubectl get pods -n production-api
echo ""
kubectl get svc -n production-api
echo ""
kubectl get hpa -n production-api
echo ""
kubectl get ingress -n production-api

echo ""
echo "🌐 Access the application:"
echo "1. Run in separate terminal: minikube tunnel"
echo "2. Add to /etc/hosts: echo \"\$(minikube ip) api.local\" | sudo tee -a /etc/hosts"
echo "3. Test: curl http://api.local/"
