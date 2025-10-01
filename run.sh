#!/bin/bash

# Build and run Stellar Core development container

set -e

echo "Stellar Core Docker Development Environment Setup"
echo "=================================================="

# Create workspace directories if they don't exist
mkdir -p workspace
mkdir -p stellar-core-config

# Check if stellar-core directory exists
if [ ! -d "stellar-core" ]; then
    echo "Cloning stellar-core repository to ./stellar-core..."
    git clone https://github.com/stellar/stellar-core
    cd stellar-core
    git checkout v23.0.0
    git submodule init && git submodule update --init --recursive
    cd ..
    echo "Repository cloned successfully!"
else
    echo "stellar-core directory already exists - will use existing source"
fi

# Build the Docker image (using docker build directly for better output)
echo ""
echo "Building Docker image with build environment..."
docker build -t stellar-core-dev:ubuntu24.04 .

echo "Docker image build complete!"
echo ""
echo "Starting container with docker-compose..."

# Start the container
docker-compose up -d

echo ""
echo "=========================================="
echo "Container started successfully!"
echo "=========================================="
echo ""
echo "The stellar-core source is mounted at: ./stellar-core"
echo "You can edit the source files with your IDE on the host!"
echo ""
echo "To enter the container and build:"
echo "  docker exec -it stellar-core-dev /bin/bash"
echo "  build-stellar-core  # Run this inside container to build"
echo ""
echo "Or build directly from host:"
echo "  docker exec -it stellar-core-dev build-stellar-core"
echo ""
echo "After building, you can run:"
echo "  docker exec -it stellar-core-dev /root/stellar-core/src/stellar-core --version"
echo ""
echo "To stop the container:"
echo "  docker-compose down"
echo ""
echo "To rebuild from scratch:"
echo "  docker-compose down"
echo "  rm -rf stellar-core"
echo "  ./build-and-run.sh"
