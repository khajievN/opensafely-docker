#!/bin/bash
set -e

# Configuration - adjust these variables as needed
export WORKDIR_BASE="$HOME/opensafely-workdir"
export GITHUB_TOKEN="your-github-token-here"  # Replace with your GitHub token
export JOB_SERVER_ENDPOINT="http://host.docker.internal:8000/api/v2/"
export JOB_SERVER_TOKEN="your-job-server-token-here"  # Replace with your token

echo "Setting up OpenSAFELY Job Runner..."

# Create directory structure
echo "Creating directory structure at $WORKDIR_BASE..."
mkdir -p "$WORKDIR_BASE/high_privacy/volumes"
mkdir -p "$WORKDIR_BASE/high_privacy/workspaces"
mkdir -p "$WORKDIR_BASE/high_privacy/logs"
mkdir -p "$WORKDIR_BASE/medium_privacy/workspaces"

# Set permissions
echo "Setting permissions..."
chmod -R 777 "$WORKDIR_BASE"

# Check if docker and docker compose are available
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed or not in PATH. Please install Docker first."
    exit 1
fi

# First, explicitly pull the required image
echo "Pulling the required Python image..."
docker pull ghcr.io/deex-network/python:v2

# Check if the container is already running
if docker ps --format '{{.Names}}' | grep -q "^opensafely-job-runner$"; then
    echo "Container opensafely-job-runner is already running. Stopping it..."
    docker compose down
fi

# Start the container with Docker Compose
echo "Starting OpenSAFELY Job Runner container with Docker Compose..."
docker compose up -d

echo "Checking container status..."
sleep 2

if docker ps --format '{{.Names}}' | grep -q "^opensafely-job-runner$"; then
    echo "✅ OpenSAFELY Job Runner is running successfully!"
    echo "Workdir location: $WORKDIR_BASE"
else
    echo "❌ Container failed to start. Check the logs with: docker compose logs"
fi