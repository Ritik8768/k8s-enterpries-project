#!/bin/bash

echo "🧪 Testing Production Kubernetes System..."
echo ""

NAMESPACE="production-api"

# Test 1: Check pods
echo "1️⃣  Checking pods..."
kubectl get pods -n $NAMESPACE
echo ""

# Test 2: Check HPA
echo "2️⃣  Checking autoscaler..."
kubectl get hpa -n $NAMESPACE
echo ""

# Test 3: Test health endpoint
echo "3️⃣  Testing health endpoint..."
POD=$(kubectl get pod -n $NAMESPACE -l app=api -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n $NAMESPACE $POD -- curl -s http://localhost:8000/health
echo ""
echo ""

# Test 4: Test API endpoint
echo "4️⃣  Testing API endpoint..."
kubectl exec -n $NAMESPACE $POD -- curl -s http://localhost:8000/api/data
echo ""
echo ""

# Test 5: Check metrics
echo "5️⃣  Checking resource metrics..."
kubectl top pods -n $NAMESPACE
echo ""

echo "✅ Tests complete!"
