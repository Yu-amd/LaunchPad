# AgentQnA Docker Compose Setup

This directory contains the Docker Compose configuration for running AgentQnA with AMD GPU support using ROCm.

## Quick Start

### Unified Management Script (Recommended)

Use the unified `run_agentqna.sh` script for all operations:

```bash
# Interactive menu with all options
./run_agentqna.sh menu

# Or use direct commands:
./run_agentqna.sh setup-tgi      # Setup TGI environment
./run_agentqna.sh setup-vllm     # Setup vLLM environment
./run_agentqna.sh start-tgi      # Start TGI services
./run_agentqna.sh start-vllm     # Start vLLM services
./run_agentqna.sh tgi-eval       # Run TGI evaluation
./run_agentqna.sh vllm-eval      # Run vLLM evaluation
./run_agentqna.sh compare-eval   # Compare TGI vs vLLM
```

## Configuration Parameters

Key parameters are configured via environment variables set before running `docker compose up`.

## Services

The following services are included for both TGI and vLLM configurations:

### TGI Services (compose.yaml)
- **Frontend**: React application (Port 5173)
- **Backend**: FastAPI server (Port 8889)
- **Retriever**: Vector search service (Port 7000)
- **Redis**: Vector database (Port 6379)
- **TGI**: Text Generation Inference (Port 80)
- **Nginx**: Reverse proxy (Port 8080)

### vLLM Services (compose_vllm.yaml)
- **Frontend**: React application (Port 5174)
- **Backend**: FastAPI server (Port 8890)
- **Retriever**: Vector search service (Port 7001)
- **Redis**: Vector database (Port 6380)
- **vLLM**: Vector Large Language Model (Port 18009)
- **Nginx**: Reverse proxy (Port 8081)

## Port Configuration

**Note**: The nginx port has been changed from 80 to 8080/8081 to avoid conflicts with common web servers like Caddy on remote nodes.

### TGI Configuration
- Frontend: http://localhost:5173
- Backend API: http://localhost:8889
- Retriever API: http://localhost:7000
- TGI API: http://localhost:80
- Nginx Proxy: http://localhost:8080 (redirects to frontend)

### vLLM Configuration
- Frontend: http://localhost:5174
- Backend API: http://localhost:8890
- Retriever API: http://localhost:7001
- vLLM API: http://localhost:18009
- Nginx Proxy: http://localhost:8081 (redirects to frontend)

## Scripts

### `run_agentqna.sh` (Recommended)
Unified management script for all AgentQnA operations:
- **Environment Setup**: `setup-tgi`, `setup-vllm`, `setup-light`
- **Service Management**: `start-tgi`, `start-vllm`, `stop-tgi`, `stop-vllm`
- **Evaluation**: `tgi-eval`, `vllm-eval`, `compare-eval`, `quick-eval`, `full-eval`
- **Monitoring**: `monitor-start`, `monitor-stop`
- **Logs & Status**: `logs-tgi`, `logs-vllm`, `status`, `cleanup`
- **Interactive Menu**: `menu` for easy navigation

### `setup_remote_node.sh`
Complete automated setup script for remote nodes that handles:
- Environment validation
- Port conflict detection
- Virtual environment setup
- Service startup
- Basic testing

### `fix_redis_index.sh`
Fixes Redis index issues common on remote nodes with newer Docker images.

### `quick_test_agentqna.sh`
Tests the complete AgentQnA system.

### `detect_issues.sh`
Detects common issues on fresh remote node deployments.

## Common Issues

### 1. Port Conflicts
If you encounter port conflicts (especially on port 80), the nginx port has been changed to 8080. If you need to change it back:

```bash
# Edit the relevant .env files to change NGINX_PORT back to 80
# Or stop conflicting services like Caddy:
sudo systemctl stop caddy
```

### 2. Redis Index Missing
Newer Docker images require the Redis index to exist before the retriever service starts:

```bash
# Automated fix
./fix_redis_index.sh

# Manual fix
docker exec agentqna-redis-vector-db redis-cli FT.CREATE rag-redis ON HASH PREFIX 1 doc: SCHEMA content TEXT WEIGHT 1.0 distance NUMERIC
```

### 3. HF Token Issues
Ensure your Hugging Face token is properly formatted in the environment file:

```bash
# Correct format
AGENTQNA_HUGGINGFACEHUB_API_TOKEN=hf_your_token_here  # Optional comment

# Incorrect format (will truncate token)
AGENTQNA_HUGGINGFACEHUB_API_TOKEN=hf_your_token_here#Optional comment
```

## Documentation

For detailed setup instructions and troubleshooting, see:
- [Remote Node Setup Guide](REMOTE_NODE_SETUP.md) - Comprehensive guide for remote deployments
- [Troubleshooting Guide](REMOTE_NODE_SETUP.md#troubleshooting-commands) - Common issues and solutions

## Development

### Building Images
```bash
# TGI services
docker compose -f compose.yaml build

# vLLM services
docker compose -f compose_vllm.yaml build
```

### Viewing Logs
```bash
# All TGI services
docker compose -f compose.yaml logs -f

# All vLLM services
docker compose -f compose_vllm.yaml logs -f

# Specific service
docker compose -f compose.yaml logs -f backend-server
docker compose -f compose_vllm.yaml logs -f backend-server
```

### Stopping Services
```bash
# TGI services
docker compose -f compose.yaml down

# vLLM services
docker compose -f compose_vllm.yaml down

# All services (using unified script)
./run_agentqna.sh cleanup
```

#### If you use vLLM:

```bash
DATA='{"model": "Intel/neural-chat-7b-v3-3t", '\
'"messages": [{"role": "user", "content": "What is Deep Learning?"}], "max_tokens": 256}'

curl http://${HOST_IP}:${VLLM_SERVICE_PORT}/v1/chat/completions \
  -X POST \
  -d "$DATA" \
  -H 'Content-Type: application/json'
```

Checking the response from the service. The response should be similar to JSON:

```json
{
  "id": "chatcmpl-142f34ef35b64a8db3deedd170fed951",
  "object": "chat.completion",
  "created": 1742270316,
  "model": "Intel/neural-chat-7b-v3-3",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "",
        "tool_calls": []
      },
      "logprobs": null,
      "finish_reason": "length",
      "stop_reason": null
    }
  ],
  "usage": { "prompt_tokens": 66, "total_tokens": 322, "completion_tokens": 256, "prompt_tokens_details": null },
  "prompt_logprobs": null
}
```

If the service response has a meaningful response in the value of the "choices.message.content" key,
then we consider the vLLM service to be successfully launched

#### If you use TGI:

```bash
DATA='{"inputs":"What is Deep Learning?",'\
'"parameters":{"max_new_tokens":256,"do_sample": true}}'

curl http://${HOST_IP}:${TGI_SERVICE_PORT}/generate \
  -X POST \
  -d "$DATA" \
  -H 'Content-Type: application/json'
```

Checking the response from the service. The response should be similar to JSON:

```json
{
  "generated_text": " "
}
```

If the service response has a meaningful response in the value of the "generated_text" key,
then we consider the TGI service to be successfully launched

### 2. Validate Agent Services

#### Validate RAG Agent Service

```bash
export agent_port=${WORKER_RAG_AGENT_PORT}
prompt="Tell me about Michael Jackson song Thriller"
python3 ~/agentqna-install/GenAIExamples/AgentQnA/tests/test.py --prompt "$prompt" --agent_role "worker" --ext_port $agent_port
```

The response must contain the meaningful text of the response to the request from the "prompt" variable

#### Validate SQL Agent Service

```bash
export agent_port=${WORKER_SQL_AGENT_PORT}
prompt="How many employees are there in the company?"
python3 ~/agentqna-install/GenAIExamples/AgentQnA/tests/test.py --prompt "$prompt" --agent_role "worker" --ext_port $agent_port
```

The answer should make sense - "8 employees in the company"

#### Validate React (Supervisor) Agent Service

```bash
export agent_port=${SUPERVISOR_REACT_AGENT_PORT}
python3 ~/agentqna-install/GenAIExamples/AgentQnA/tests/test.py --agent_role "supervisor" --ext_port $agent_port --stream
```

The response should contain "Iron Maiden"

## Conclusion

This guide provides a comprehensive workflow for deploying, configuring, and validating the AgentQnA system on AMD GPU (ROCm), enabling flexible integration with both OpenAI-compatible and remote LLM services.
