#!/bin/bash

# AgentQnA Quick Start vLLM Script
# This script provides a quick way to start AgentQnA with vLLM backend

set -e

echo "🚀 Starting AgentQnA with vLLM Backend"
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
    if [[ ! -f "compose_vllm.yaml" ]]; then
        print_error "compose_vllm.yaml not found. Please ensure you're in the correct directory."
        exit 1
    fi
}

# Main execution
main() {
    check_docker
    check_requirements
    
    # Source vLLM environment
    source set_env_vllm.sh
    
    # Start services
    print_status "Starting AgentQnA services with vLLM..."
    docker compose -f compose_vllm.yaml up -d
    
    # Wait for services to be ready
    print_status "Waiting for services to be ready..."
    sleep 30
    
    # Verify services are running
    if ! docker ps --format "{{.Names}}" | grep -q "agentqna"; then
        print_error "Services failed to start. Please check logs for errors."
        exit 1
    fi
    
    print_success "AgentQnA services started successfully!"
    print_status "vLLM Service: http://localhost:${AGENTQNA_VLLM_SERVICE_PORT}"
    print_status "RAG Agent: http://localhost:${WORKER_RAG_AGENT_PORT}"
    print_status "SQL Agent: http://localhost:${WORKER_SQL_AGENT_PORT}"
    print_status "React Agent: http://localhost:${SUPERVISOR_REACT_AGENT_PORT}"
}

main "$@"
