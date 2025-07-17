#!/bin/bash

# Remote Node Setup Script for AgentQnA
# This script handles all the common issues when setting up AgentQnA on remote nodes
# including HF token authentication, port conflicts, and Redis index issues

set -e

echo "🚀 AgentQnA Remote Node Setup Script"
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

# Check if we're in the right directory
check_directory() {
    print_status "Checking current directory..."
    
    if [ ! -f "compose.yaml" ]; then
        print_error "Please run this script from the AgentQnA docker-compose directory"
        print_status "Expected location: docker_compose/amd/gpu/rocm/"
        exit 1
    fi
    
    print_success "Found compose.yaml in current directory"
}

# Check and fix HF token
fix_hf_token() {
    print_status "Checking Hugging Face token configuration..."
    
    if [ -f "set_env.sh" ]; then
        # Check if HF_TOKEN exists and is properly formatted
        if grep -q "^AGENTQNA_HUGGINGFACEHUB_API_TOKEN=" set_env.sh; then
            token_line=$(grep "^AGENTQNA_HUGGINGFACEHUB_API_TOKEN=" set_env.sh)
            
            # Check if token has a comment without space (common issue)
            if echo "$token_line" | grep -q "hf_"; then
                if echo "$token_line" | grep -q "#"; then
                    print_warning "Found HF_TOKEN with comment, checking format..."
                    
                    # Extract token and check if it's truncated
                    token=$(echo "$token_line" | cut -d'=' -f2 | cut -d'#' -f1 | tr -d ' ')
                    
                    if [ ${#token} -lt 30 ]; then
                        print_error "HF_TOKEN appears to be truncated due to comment format"
                        print_status "Please update set_env.sh file to ensure proper token format:"
                        echo "  AGENTQNA_HUGGINGFACEHUB_API_TOKEN=your_token_here  # Optional comment"
                        echo ""
                        echo "Make sure there's a space before the # comment"
                        return 1
                    fi
                fi
            fi
        else
            print_warning "AGENTQNA_HUGGINGFACEHUB_API_TOKEN not found in set_env.sh"
            print_status "Please add your Hugging Face token to set_env.sh:"
            echo "  AGENTQNA_HUGGINGFACEHUB_API_TOKEN=your_token_here"
            return 1
        fi
    else
        print_warning "set_env.sh file not found"
        print_status "Please create set_env.sh file with your HF_TOKEN"
        return 1
    fi
    
    print_success "HF_TOKEN configuration looks good"
    return 0
}

# Check for port conflicts
check_port_conflicts() {
    print_status "Checking for port conflicts..."
    
    conflicts=()
    
    # Check port 80 (common conflict with Caddy)
    if netstat -tlnp 2>/dev/null | grep -q ":80 "; then
        conflicts+=("80")
    fi
    
    # Check other important ports
    ports=(18008 18009 7001 7002 7003 8890 9090 3000)
    
    for port in "${ports[@]}"; do
        if netstat -tlnp 2>/dev/null | grep -q ":$port "; then
            conflicts+=($port)
        fi
    done
    
    if [ ${#conflicts[@]} -gt 0 ]; then
        print_warning "Found port conflicts:"
        for port in "${conflicts[@]}"; do
            echo "  - Port $port is in use"
        done
        print_status "Please stop services using these ports or change the configuration in set_env.sh"
        return 1
    fi
    
    print_success "No port conflicts found"
    return 0
}

# Setup virtual environment
setup_virtual_env() {
    print_status "Setting up virtual environment..."
    
    if [ ! -d ".venv" ]; then
        python3 -m venv .venv
        print_success "Virtual environment created"
    else
        print_status "Virtual environment already exists"
    fi
    
    source .venv/bin/activate
    pip install -r requirements.txt
    
    if [ $? -eq 0 ]; then
        print_success "Virtual environment setup complete"
    else
        print_error "Failed to set up virtual environment"
        return 1
    fi
}

# Start services
start_services() {
    print_status "Starting AgentQnA services..."
    
    # First check and fix Redis index
    ./fix_redis_index.sh
    
    # Start services
    docker compose -f compose.yaml up -d
    
    if [ $? -eq 0 ]; then
        print_success "Services started successfully"
    else
        print_error "Failed to start services"
        return 1
    fi
}

# Test services
test_services() {
    print_status "Testing services..."
    
    # Test Redis index
    ./fix_redis_index.sh test-only
    
    # Test backend
    print_status "Testing backend service..."
    response=$(curl -s -w "\n%{http_code}" http://localhost:8890/v1/agentqna \
        -H "Content-Type: application/json" \
        -d '{"messages": [{"role": "user", "content": "test"}]}' 2>/dev/null || echo "Connection failed")
    
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "200" ]; then
        print_success "Backend service is working correctly!"
        print_status "Response: $response_body"
    else
        print_error "Backend service is not responding (HTTP $http_code)"
        print_status "Response: $response_body"
        return 1
    fi
    
    # Test monitoring
    print_status "Testing monitoring..."
    ./start_monitoring.sh
    
    if [ $? -eq 0 ]; then
        print_success "Monitoring services started successfully"
        print_status "Grafana: http://localhost:3000"
        print_status "Prometheus: http://localhost:9090"
    else
        print_warning "Failed to start monitoring services"
    fi
}

# Main execution
main() {
    # Check directory
    check_directory
    
    # Check HF token
    if ! fix_hf_token; then
        print_error "HF token configuration issues found"
        exit 1
    fi
    
    # Check port conflicts
    if ! check_port_conflicts; then
        print_error "Port conflicts found"
        exit 1
    fi
    
    # Setup virtual environment
    if ! setup_virtual_env; then
        print_error "Failed to set up virtual environment"
        exit 1
    fi
    
    # Start services
    if ! start_services; then
        print_error "Failed to start services"
        exit 1
    fi
    
    # Test services
    if ! test_services; then
        print_error "Service tests failed"
        exit 1
    fi
    
    print_success "AgentQnA Remote Node Setup Complete!"
    print_status "Services are running at:"
    echo "  Backend: http://localhost:8890"
    echo "  Frontend: http://localhost:8081"
    echo "  Monitoring:"
    echo "    Grafana: http://localhost:3000"
    echo "    Prometheus: http://localhost:9090"
}

# Handle command line arguments
case "${1:-}" in
    "check-only")
        check_directory
        fix_hf_token
        check_port_conflicts
        ;;
    "setup-only")
        setup_virtual_env
        ;;
    "start-only")
        start_services
        ;;
    "test-only")
        test_services
        ;;
    *)
        main "$@"
        ;;
esac
