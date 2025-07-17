#!/bin/bash

# AgentQnA Quick Test Script
# This script provides a quick way to test AgentQnA services

set -e

echo "🚀 Quick Testing AgentQnA Services"
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
    if [[ ! -f "set_env.sh" ]]; then
        print_error "set_env.sh not found. Please ensure you're in the correct directory."
        exit 1
    fi
}

# Test AgentQnA services
run_tests() {
    # Source environment variables
    source set_env.sh
    
    # Test RAG Agent
    print_status "Testing RAG Agent..."
    curl -X POST "http://localhost:${WORKER_RAG_AGENT_PORT}/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -d '{"messages":[{"role":"user","content":"What is AgentQnA?"}]}'
    
    # Test SQL Agent
    print_status "Testing SQL Agent..."
    curl -X POST "http://localhost:${WORKER_SQL_AGENT_PORT}/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -d '{"messages":[{"role":"user","content":"What SQL queries can I run?"}]}'
    
    # Test React Agent
    print_status "Testing React Agent..."
    curl -X POST "http://localhost:${SUPERVISOR_REACT_AGENT_PORT}/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -d '{"messages":[{"role":"user","content":"How does AgentQnA work?"}]}'
    
    print_success "All tests completed successfully!"
}

main() {
    check_docker
    check_requirements
    run_tests
}

main "$@"
