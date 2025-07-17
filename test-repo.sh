#!/bin/bash

# Local test script for Helm repository
# This script tests the repository locally before deploying

set -e

echo "🚀 Testing Helm Repository Locally"
echo "=================================="

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install Helm first."
    exit 1
fi

# Build the repository
echo "📦 Building repository..."
make clean
make all

# Check if files were created
if [ ! -f "index.yaml" ]; then
    echo "❌ index.yaml not found!"
    exit 1
fi

if [ ! -d "packages" ]; then
    echo "❌ packages directory not found!"
    exit 1
fi

echo "✅ Repository built successfully!"

# Start local server in background
echo "🌐 Starting local server..."
python3 -m http.server 8080 &
SERVER_PID=$!

# Wait for server to start
sleep 2

# Test the repository
echo "🧪 Testing repository..."

# Remove existing local repo if it exists
helm repo remove local 2>/dev/null || true

# Add local repository
if helm repo add local http://localhost:8080; then
    echo "✅ Repository added successfully!"
else
    echo "❌ Failed to add repository!"
    kill $SERVER_PID
    exit 1
fi

# Update repository
if helm repo update; then
    echo "✅ Repository updated successfully!"
else
    echo "❌ Failed to update repository!"
    kill $SERVER_PID
    exit 1
fi

# Search for charts
echo "🔍 Searching for charts..."
helm search repo local

# Test chart installation (dry-run)
echo "🧪 Testing chart installation (dry-run)..."
if helm install --dry-run --debug test-release local/ankra-monitoring-stack; then
    echo "✅ Chart installation test passed!"
else
    echo "❌ Chart installation test failed!"
    kill $SERVER_PID
    exit 1
fi

# Cleanup
echo "🧹 Cleaning up..."
helm repo remove local
kill $SERVER_PID

echo ""
echo "🎉 All tests passed!"
echo "Your Helm repository is ready for deployment!"
echo ""
echo "To deploy:"
echo "1. Push your changes to GitHub"
echo "2. GitHub Actions will automatically build and deploy"
echo "3. Your repository will be available at: https://ankraio.github.io/charts"
echo ""
echo "Users can then add it with:"
echo "helm repo add ankra https://ankraio.github.io/charts"
