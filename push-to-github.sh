#!/bin/bash

echo "🚀 Pushing to GitHub..."
echo ""
echo "⚠️  You will be prompted for:"
echo "   Username: YOUR_GITHUB_USERNAME"
echo "   Password: YOUR_NEW_GITHUB_TOKEN"
echo ""

cd ~/k8s-production-project

# Set main branch
git branch -M main

# Add remote (replace YOUR_USERNAME)
read -p "Enter your GitHub username: " username
git remote add origin https://github.com/$username/k8s-production-project.git

# Push
git push -u origin main

echo ""
echo "✅ Done! Check: https://github.com/$username/k8s-production-project"
