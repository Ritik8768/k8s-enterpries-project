#!/bin/bash

IMAGE=${1:-api-app:v1.0}

echo "🔍 Scanning image: $IMAGE"
echo ""

if ! command -v trivy &> /dev/null; then
    echo "❌ Trivy not installed!"
    echo "Install: curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin"
    exit 1
fi

# Scan for HIGH and CRITICAL vulnerabilities
trivy image --severity HIGH,CRITICAL $IMAGE

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Image scan passed - No HIGH/CRITICAL vulnerabilities"
else
    echo "⚠️  Vulnerabilities found - Review and fix before production"
fi

echo ""
echo "Full report: trivy image $IMAGE"
