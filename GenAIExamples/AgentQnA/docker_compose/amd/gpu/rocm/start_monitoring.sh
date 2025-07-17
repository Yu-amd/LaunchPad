#!/bin/bash

# Start AgentQnA Monitoring Stack
# This script starts Prometheus and Grafana for monitoring AgentQnA performance

set -e

echo "🚀 Starting AgentQnA Monitoring Stack"
echo "===================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Check if required files exist
check_requirements() {
    if [[ ! -f "compose.telemetry.yaml" ]]; then
        print_error "compose.telemetry.yaml not found. Please ensure you're in the correct directory."
        exit 1
    fi
}

# Main execution
main() {
    check_docker
    check_requirements
    
    print_status "Starting monitoring services..."
    docker compose -f compose.telemetry.yaml up -d
    
    print_success "Monitoring services started successfully!"
    print_status "Access Grafana at: http://localhost:3000"
    print_status "Access Prometheus at: http://localhost:9090"
}

main "$@"
