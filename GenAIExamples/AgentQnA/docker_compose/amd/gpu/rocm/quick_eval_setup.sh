#!/bin/bash

# AgentQnA Quick Evaluation Setup Script
# This script sets up a minimal environment for quick evaluation

set -e

echo "🚀 Setting up AgentQnA Quick Evaluation Environment"
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
    if [[ ! -f "set_env_lightweight.sh" ]]; then
        print_error "set_env_lightweight.sh not found. Please ensure you're in the correct directory."
        exit 1
    fi
}

# Main setup function
setup_evaluation() {
    # Source lightweight environment
    source set_env_lightweight.sh
    
    # Create evaluation directory if it doesn't exist
    mkdir -p evaluation_results
    
    # Start services
    print_status "Starting lightweight services..."
    docker compose -f compose.yaml up -d
    
    # Wait for services to be ready
    print_status "Waiting for services to be ready..."
    sleep 30
    
    # Verify services are running
    if ! docker ps --format "{{.Names}}" | grep -q "agentqna"; then
        print_error "Services failed to start. Please check logs for errors."
        exit 1
    fi
    
    print_success "Quick evaluation environment setup complete!"
    print_status "You can now run evaluations using:"
    print_status "  ./performance_evaluation.sh"
    print_status "  ./run_agentqna.sh eval"
}

main() {
    check_docker
    check_requirements
    setup_evaluation
}

main "$@"
