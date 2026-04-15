#!/bin/bash

echo "🔥 Starting Locust Load Testing..."
echo ""
echo "📊 Test Configuration:"
echo "   Target: http://api.local"
echo "   Test File: tests/locustfile.py"
echo ""
echo "🌐 Access Locust Web UI:"
echo "   http://localhost:8089"
echo ""
echo "⚙️  Recommended Settings:"
echo "   Users: 50-100"
echo "   Spawn Rate: 10 users/sec"
echo "   Duration: 5 minutes"
echo ""
echo "📈 Watch HPA scaling:"
echo "   kubectl get hpa -n production-api -w"
echo ""
echo "Starting Locust..."
echo ""

cd ~/k8s-production-project
locust -f tests/locustfile.py --host=http://api.local
