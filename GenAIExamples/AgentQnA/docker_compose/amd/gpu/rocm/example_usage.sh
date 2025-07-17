#!/bin/bash

# AgentQnA Example Usage Script
# This script demonstrates how to interact with the AgentQnA system

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Configuration
BACKEND_URL="http://localhost:8890/v1/agentqna"
DATAPREP_URL="http://localhost:18104/v1/dataprep/ingest"
FRONTEND_URL="http://localhost:8081"

# Function to check if services are running
check_services() {
    print_header "Checking Service Status"
    
    if ! docker ps --format "{{.Names}}" | grep -q "agentqna-vllm-service"; then
        print_warning "vLLM services are not running. Please start them first:"
        print_status "./run_agentqna.sh start-vllm"
        exit 1
    fi
    
    print_status "vLLM services are running"
}

# Function to upload sample documents
upload_documents() {
    print_header "Uploading Sample Documents"
    
    # Sample documents for testing
    documents=(
        '{"file_name": "ai_introduction.txt", "content": "Artificial Intelligence (AI) is a branch of computer science that aims to create intelligent machines that work and react like humans. Some of the activities computers with artificial intelligence are designed for include speech recognition, learning, planning, and problem solving."}'
        '{"file_name": "machine_learning.txt", "content": "Machine Learning is a subset of artificial intelligence that enables computers to learn and improve from experience without being explicitly programmed. It focuses on developing computer programs that can access data and use it to learn for themselves."}'
        '{"file_name": "deep_learning.txt", "content": "Deep Learning is a subset of machine learning that uses neural networks with multiple layers to model and understand complex patterns. It has been particularly successful in areas like image recognition, natural language processing, and speech recognition."}'
        '{"file_name": "neural_networks.txt", "content": "Neural Networks are computing systems inspired by biological neural networks. They consist of interconnected nodes (neurons) that process information and can learn to recognize patterns in data."}'
        '{"file_name": "nlp_overview.txt", "content": "Natural Language Processing (NLP) is a field of artificial intelligence that focuses on the interaction between computers and human language. It involves developing algorithms and models that can understand, interpret, and generate human language."}'
    )
    
    for doc in "${documents[@]}"; do
        print_status "Uploading document..."
        response=$(curl -s -X POST "$DATAPREP_URL" \
            -H "Content-Type: application/json" \
            -d "$doc")
        
        if [ $? -eq 0 ]; then
            print_status "✓ Document uploaded successfully"
        else
            print_warning "⚠ Failed to upload document"
        fi
    done
}

# Function to ask questions
ask_questions() {
    print_header "Asking Sample Questions"
    
    # Sample questions
    questions=(
        "What is artificial intelligence?"
        "How does machine learning work?"
        "Explain deep learning"
        "What are neural networks?"
        "What is natural language processing?"
    )
    
    for question in "${questions[@]}"; do
        print_status "Question: $question"
        
        response=$(curl -s "$BACKEND_URL" \
            -H "Content-Type: application/json" \
            -d "{\"messages\": [{\"role\": \"user\", \"content\": \"$question\"}]}")
        
        if [ $? -eq 0 ]; then
            # Extract the answer from the response (assuming JSON format)
            answer=$(echo "$response" | grep -o '"content":"[^"]*"' | cut -d'"' -f4)
            if [ -n "$answer" ]; then
                echo "Answer: $answer"
            else
                echo "Response: $response"
            fi
        else
            print_warning "⚠ Failed to get response"
        fi
        echo ""
    done
}

# Function to demonstrate batch processing
batch_processing() {
    print_header "Demonstrating Batch Processing"
    
    # Sample batch of questions
    batch_questions=(
        "{"messages": [{"role": "user", "content": "What is deep learning?"}]}"
        "{"messages": [{"role": "user", "content": "How does neural networks work?"}]}"
        "{"messages": [{"role": "user", "content": "Explain natural language processing"}]}"
    )
    
    print_status "Sending batch of questions..."
    
    for question in "${batch_questions[@]}"; do
        response=$(curl -s "$BACKEND_URL" \
            -H "Content-Type: application/json" \
            -d "$question")
        
        if [ $? -eq 0 ]; then
            answer=$(echo "$response" | grep -o '"content":"[^"]*"' | cut -d'"' -f4)
            echo "Answer: $answer"
        else
            print_warning "⚠ Failed to process batch item"
        fi
    done
}

# Function to demonstrate error handling
error_handling() {
    print_header "Demonstrating Error Handling"
    
    # Test invalid request
    print_status "Sending invalid request..."
    response=$(curl -s "$BACKEND_URL" \
        -H "Content-Type: application/json" \
        -d "{\"invalid\": \"data\"}")
    
    if [ $? -ne 0 ]; then
        print_warning "✓ Error handling works as expected"
        echo "Response: $response"
    fi
}

# Function to demonstrate API endpoints
show_api_endpoints() {
    print_header "Available API Endpoints"
    
    echo "1. Backend API: $BACKEND_URL"
    echo "   - POST /v1/agentqna - Process messages"
    echo "   - GET /health - Check service health"
    
    echo "2. Dataprep Service: $DATAPREP_URL"
    echo "   - POST /v1/dataprep/ingest - Upload documents"
    echo "   - GET /v1/dataprep/status - Check ingestion status"
    
    echo "3. Frontend: $FRONTEND_URL"
    echo "   - Web interface for agent interactions"
}

# Function to demonstrate monitoring
show_monitoring() {
    print_header "Monitoring Dashboard"
    
    echo "Grafana Dashboard: http://localhost:3000"
    echo "Default credentials: admin/admin"
    echo ""
    echo "Available metrics:"
    echo "- Request rate"
    echo "- Response time"
    echo "- GPU utilization"
    echo "- Memory usage"
    echo "- Service health"
}

# Function to show help
show_help() {
    print_header "Usage"
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  check-services    Check if services are running"
    echo "  upload-docs       Upload sample documents"
    echo "  ask-questions     Ask sample questions"
    echo "  batch-process     Demonstrate batch processing"
    echo "  error-test        Test error handling"
    echo "  show-apis         Show available API endpoints"
    echo "  show-monitoring   Show monitoring dashboard info"
    echo "  help             Show this help message"
}

# Main script logic
main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    case $1 in
        check-services)
            check_services
            ;;
        upload-docs)
            check_services
            upload_documents
            ;;
        ask-questions)
            check_services
            ask_questions
            ;;
        batch-process)
            check_services
            batch_processing
            ;;
        error-test)
            check_services
            error_handling
            ;;
        show-apis)
            show_api_endpoints
            ;;
        show-monitoring)
            show_monitoring
            ;;
        help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
