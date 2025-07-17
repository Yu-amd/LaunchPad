#!/bin/bash

# Fix Redis Index Script for AgentQnA Remote Nodes
# This script fixes the "rag-redis: no such index" error on remote nodes
# with newer Docker images that have stricter error handling

set -e

echo "🔧 Fixing Redis Index for AgentQnA Remote Node"
echo "=============================================="

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

# Check if services are running
check_services() {
    print_status "Checking if AgentQnA services are running..."
    
    if docker ps --format "{{.Names}}" | grep -q "agentqna-backend-server"; then
        print_success "AgentQnA services are running"
        return 0
    else
        print_error "AgentQnA services are not running. Please start them first with:"
        echo "  ./run_agentqna.sh start"
        exit 1
    fi
}

# Check if Redis index exists
check_redis_index() {
    print_status "Checking if Redis index exists..."
    
    # Connect to Redis and check if rag-redis index exists
    if docker exec agentqna-redis-vector-db redis-cli FT.INFO rag-redis > /dev/null 2>&1; then
        print_success "Redis index 'rag-redis' already exists"
        return 0
    else
        print_warning "Redis index 'rag-redis' does not exist. Creating it..."
        return 1
    fi
}

# Create Redis index
create_redis_index() {
    print_status "Creating Redis index 'rag-redis'..."
    
    # Create the index with the correct schema
    docker exec agentqna-redis-vector-db redis-cli FT.CREATE rag-redis ON HASH PREFIX 1 doc: SCHEMA content TEXT WEIGHT 1.0 distance NUMERIC
    
    if [ $? -eq 0 ]; then
        print_success "Redis index 'rag-redis' created successfully"
    else
        print_error "Failed to create Redis index"
        exit 1
    fi
}

# Test retriever service
test_retriever() {
    print_status "Testing retriever service..."
    
    response=$(curl -s -w "\n%{http_code}" http://localhost:7001/v1/retrieval \
        -H "Content-Type: application/json" \
        -d '{"query": "test", "top_k": 3}' 2>/dev/null || echo "Connection failed")
    
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "200" ]; then
        print_success "Retriever service is working correctly!"
        print_status "Response: $response_body"
    else
        print_error "Retriever service is still failing (HTTP $http_code)"
        print_status "Response: $response_body"
        exit 1
    fi
}

# Test backend service
test_backend() {
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
        print_error "Backend service is still failing (HTTP $http_code)"
        print_status "Response: $response_body"
        exit 1
    fi
}

# Main execution
main() {
    # Check if services are running
    check_services
    
    # Check if Redis index exists
    if ! check_redis_index; then
        # Create the index if it doesn't exist
        create_redis_index
    fi
    
    # Test services
    test_retriever
    test_backend
}

# Handle command line arguments
case "${1:-}" in
    "check-only")
        check_services
        check_redis_index
        ;;
    "create-only")
        check_services
        create_redis_index
        ;;
    "test-only")
        test_retriever
        test_backend
        ;;
    *)
        main "$@"
        ;;
esac
