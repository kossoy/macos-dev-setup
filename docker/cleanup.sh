#!/bin/bash
# Docker cleanup script for macOS Fresh Setup Package

echo "🧹 Cleaning up Docker containers and networks..."

# Stop and remove all containers for this project
docker compose -f docker/docker-compose.yml down --remove-orphans

# Remove any dangling images
docker image prune -f

# Remove any unused networks
docker network prune -f

echo "✅ Docker cleanup complete!"
echo ""
echo "To run tests again:"
echo "  docker compose -f docker/docker-compose.yml run test-environment"
echo ""
echo "To run interactive testing:"
echo "  docker compose -f docker/docker-compose.yml up --build"
