#!/bin/bash
# =============================================================================
# Docker Desktop Installation Script
# =============================================================================
# Installs Docker Desktop for Mac with verification
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check for non-interactive flag
NON_INTERACTIVE=false
if [[ "$1" == "--non-interactive" ]]; then
    NON_INTERACTIVE=true
fi

print_status "Installing Docker Desktop..."

# Check if Docker is already installed
if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
    print_success "Docker is already installed and running"
    docker --version
    docker compose version
    exit 0
fi

# Check if Docker command exists but daemon isn't running
if command -v docker &>/dev/null; then
    print_status "Docker is installed but not running"
    print_status "Starting Docker Desktop..."

    # Try to start Docker Desktop
    if [[ -d "/Applications/Docker.app" ]]; then
        open -a Docker
        print_status "Waiting for Docker daemon to start..."

        # Wait for Docker daemon (max 60 seconds)
        for i in {1..30}; do
            if docker info &>/dev/null 2>&1; then
                print_success "Docker is now running"
                docker --version
                docker compose version
                exit 0
            fi
            sleep 2
        done

        print_error "Docker daemon failed to start after 60 seconds"
        print_status "Please start Docker Desktop manually and try again"
        exit 1
    fi
fi

# Check if Homebrew is available
if ! command -v brew &>/dev/null; then
    print_error "Homebrew is not installed. Please install Homebrew first:"
    echo "  ./setup-helpers/01-install-homebrew.sh"
    exit 1
fi

# Install Docker Desktop via Homebrew
print_status "Installing Docker Desktop via Homebrew..."
print_warning "This may take several minutes to download and install..."

if brew install --cask docker; then
    print_success "Docker Desktop installed"
else
    print_error "Failed to install Docker Desktop"
    exit 1
fi

# Start Docker Desktop
print_status "Starting Docker Desktop..."
open -a Docker

# Wait for Docker daemon to start
print_status "Waiting for Docker daemon to start (this may take 1-2 minutes)..."
for i in {1..60}; do
    if docker info &>/dev/null 2>&1; then
        print_success "Docker is now running"
        break
    fi
    sleep 2

    if [[ $i -eq 60 ]]; then
        print_error "Docker daemon failed to start after 120 seconds"
        print_warning "Docker Desktop is installed but may need manual configuration"
        print_status "Please:"
        echo "  1. Open Docker Desktop from Applications"
        echo "  2. Complete the initial setup"
        echo "  3. Verify with: docker --version"
        exit 1
    fi
done

# Verify installation
print_status "Verifying Docker installation..."
docker --version
docker compose version

# Test Docker
print_status "Testing Docker with hello-world..."
if docker run --rm hello-world &>/dev/null; then
    print_success "Docker is working correctly"
else
    print_warning "Docker test failed, but installation appears successful"
fi

print_success "Docker Desktop installation complete"
echo ""
print_status "Docker Desktop is installed at: /Applications/Docker.app"
print_status "To manage Docker: open -a Docker"
