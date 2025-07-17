#!/bin/bash

# AgentQnA Performance Evaluation Script
# This script runs comprehensive performance tests on AgentQnA services

set -e

echo "🚀 Starting AgentQnA Performance Evaluation"
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

# Main evaluation function
run_evaluation() {
    # Source environment variables
    source set_env.sh
    
    # Check if services are running
    print_status "Checking service status..."
    TGI_RUNNING=$(docker ps --format "{{.Names}}" | grep -q "agentqna-tgi-service" && echo "yes" || echo "no")
    VLLM_RUNNING=$(docker ps --format "{{.Names}}" | grep -q "agentqna-vllm-service" && echo "yes" || echo "no")
    
    if [[ "$TGI_RUNNING" != "yes" && "$VLLM_RUNNING" != "yes" ]]; then
        print_error "No AgentQnA services are running. Please start the services first."
        exit 1
    fi
    
    # Run evaluation
    print_status "Running performance evaluation..."
    
    # Evaluate TGI if running
    if [[ "$TGI_RUNNING" == "yes" ]]; then
        print_status "Evaluating TGI performance..."
        python evals/benchmark/agentqna_performance_eval.py \
            --service tgi \
            --output evaluation_results/tgi_performance.json
        
        print_success "TGI evaluation complete"
    fi
    
    # Evaluate vLLM if running
    if [[ "$VLLM_RUNNING" == "yes" ]]; then
        print_status "Evaluating vLLM performance..."
        python evals/benchmark/agentqna_performance_eval.py \
            --service vllm \
            --output evaluation_results/vllm_performance.json
        
        print_success "vLLM evaluation complete"
    fi
    
    print_success "Performance evaluation completed successfully!"
    print_status "Results saved to evaluation_results/ directory"
}

main() {
    check_docker
    check_requirements
    run_evaluation
}

main "$@"
