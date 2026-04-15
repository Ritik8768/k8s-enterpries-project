#!/bin/bash

echo "🔨 Building Docker image..."

cd app/

# Build image
docker build -t api-app:v1.0 .

# Load into minikube
echo "📦 Loading image into Minikube..."
minikube image load api-app:v1.0

echo "✅ Image built and loaded!"
echo ""
echo "Next: Scan the image with ./scripts/scan-image.sh"
