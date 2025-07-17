# Deploy AgentQnA on AMD GPU (ROCm)

This document outlines the single node deployment process for an AgentQnA application utilizing the GenAIComps microservices on AMD GPU (ROCm) server. The steps include pulling Docker images, container deployment via Docker Compose, and service execution using microservices agent.

## Table of Contents
- [AgentQnA Quick Start Deployment](#agentqna-quick-start-deployment)
- [Configuration Parameters](#configuration-parameters)
- [AgentQnA Docker Compose Files](#agentqna-docker-compose-files)
- [Validate Services](#validate-services)
- [Conclusion](#conclusion)

## AgentQnA Quick Start Deployment

This section describes how to quickly deploy and test the AgentQnA service manually on AMD GPU (ROCm) server. The basic steps are:

1. Access the Code
2. Configure the Deployment Environment
3. Deploy the Services Using Docker Compose
4. Validate the Services
5. Cleanup the Deployment

### Access the Code

Clone the GenAIExample repository and access the AgentQnA AMD GPU (ROCm) server Docker Compose files and supporting scripts:

```bash
export WORKDIR=<your-work-directory>
cd $WORKDIR
git clone https://github.com/opea-project/GenAIExamples.git
cd GenAIExamples/AgentQnA
```

Then checkout a released version, such as v1.4:

```bash
git checkout v1.4
```

### Configure the Deployment Environment

```bash
# Replace the string 'server_address' with your local server IP address
export host_ip='server_address'
# Replace the string 'your_huggingfacehub_token' with your HuggingFacehub repository access token.
export HF_TOKEN='your_huggingfacehub_token'
# Replace the string 'your_langchain_api_key' with your LANGCHAIN API KEY.
export LANGCHAIN_API_KEY='your_langchain_api_key'
export LANGCHAIN_TRACING_V2=""
```

### Deploy the Services Using Docker Compose

#### If you use vLLM

```bash
cd GenAIExamples/AgentQnA/docker_compose/amd/gpu/rocm
bash launch_agent_service_vllm_rocm.sh
```

#### If you use TGI

```bash
cd GenAIExamples/AgentQnA/docker_compose/amd/gpu/rocm
bash launch_agent_service_tgi_rocm.sh
```

### Check the Deployment Status

After launching agent services, check if all the containers launched via docker compose have started:

#### If you use vLLM
- dataprep-redis-server
- doc-index-retriever-server
- embedding-server
- rag-agent-endpoint
- react-agent-endpoint
- redis-vector-db
- reranking-tei-xeon-server
- retriever-redis-server
- sql-agent-endpoint
- tei-embedding-server
- tei-reranking-server
- vllm-service

#### If you use TGI
- dataprep-redis-server
- doc-index-retriever-server
- embedding-server
- rag-agent-endpoint
- react-agent-endpoint
- redis-vector-db
- reranking-tei-xeon-server
- retriever-redis-server
- sql-agent-endpoint
- tei-embedding-server
- tei-reranking-server
- tgi-service

### Cleanup the Deployment

To stop the containers associated with the deployment, execute the following command:

#### If you use vLLM

```bash
cd GenAIExamples/AgentQnA/docker_compose/amd/gpu/rocm
bash stop_agent_service_vllm_rocm.sh
```

#### If you use TGI

```bash
cd GenAIExamples/AgentQnA/docker_compose/amd/gpu/rocm
bash stop_agent_service_tgi_rocm.sh
```

## Configuration Parameters

Key parameters are configured via environment variables set before running docker compose up.

| Environment Variable | Description | Default (Set Externally) |
|----------------------|-------------|--------------------------|
| ip_address | External IP address of the host machine. Required. | your_external_ip_address |
| HF_TOKEN | Your Hugging Face Hub token for model access. Required. | your_huggingface_token |
| VLLM_LLM_MODEL_ID | Hugging Face model ID for the AgentQnA LLM. Configured within compose.yaml environment. | Intel/neural-chat-7b-v3-3 |
| TOOLSET_PATH | Local path to the tool Yaml file. Configured in compose.yaml. | ${WORKPATH}/../../../tools/ |
| CRAG_SERVER | CRAG server URL. Derived from ip_address and port 8080. | http://${ip_address}:8080 |
| WORKER_AGENT_URL | Worker agent URL. Derived from ip_address and port 9095. | http://${ip_address}:9095/v1/chat/completions |
| SQL_AGENT_URL | SQL agent URL. Derived from ip_address and port 9096. | http://${ip_address}:9096/v1/chat/completions |
| http_proxy / https_proxy/no_proxy | Network proxy settings (if required). | "" |

## AgentQnA Docker Compose Files

In the context of deploying an AgentQnA pipeline on an AMD GPU (ROCm) platform, we can pick and choose different large language model serving frameworks. The table below outlines the various configurations that are available as part of the application. These configurations can be used as templates and can be extended to different components available in GenAIComps.

| File | Description |
|------|-------------|
| compose.yaml | Default compose file using tgi as serving framework |
| compose_vllm.yaml | The LLM serving framework is vLLM. All other configurations remain the same as the default |

## Validate Services

### 1. Validate the vLLM/TGI Service

#### If you use vLLM:

```bash
DATA='{"model": "Intel/neural-chat-7b-v3-3t", \
"messages": [{"role": "user", "content": "What is Deep Learning?"}], "max_tokens": 256}'

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

If the service response has a meaningful response in the value of the "choices.message.content" key, then we consider the vLLM service to be successfully launched.

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

If the service response has a meaningful response in the value of the "generated_text" key, then we consider the TGI service to be successfully launched.

### 2. Validate Agent Services

#### Validate RAG Agent Service

```bash
export agent_port=${WORKER_RAG_AGENT_PORT}
prompt="Tell me about Michael Jackson song Thriller"
python3 ~/agentqna-install/GenAIExamples/AgentQnA/tests/test.py --prompt "$prompt" --agent_role "worker" --ext_port $agent_port
```

The response must contain the meaningful text of the response to the request from the "prompt" variable.

#### Validate SQL Agent Service

```bash
export agent_port=${WORKER_SQL_AGENT_PORT}
prompt="How many employees are there in the company?"
python3 ~/agentqna-install/GenAIExamples/AgentQnA/tests/test.py --prompt "$prompt" --agent_role "worker" --ext_port $agent_port
```

The answer should make sense - "8 employees in the company".

#### Validate React (Supervisor) Agent Service

```bash
export agent_port=${SUPERVISOR_REACT_AGENT_PORT}
python3 ~/agentqna-install/GenAIExamples/AgentQnA/tests/test.py --agent_role "supervisor" --ext_port $agent_port --stream
```

The response should contain "Iron Maiden".

## Conclusion

This guide provides a comprehensive workflow for deploying, configuring, and validating the AgentQnA system on AMD GPU (ROCm), enabling flexible integration with both OpenAI-compatible and remote LLM services.

### Service Components

```
┌───────────────────────────────────────────────────────────────────────────────────┐
│                               EXTERNAL ACCESS                                     │
│                                                                                   │
│   ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────────┐   │
│   │   Web Browser   │    │   API Clients   │    │      Monitoring Tools       │   │
│   │                 │    │                 │    │    (Grafana, Prometheus)    │   │
│   └─────────────────┘    └─────────────────┘    └─────────────────────────────┘   │
│           │                       │                           │                   │
│           │                       │                           │                   │
│           ▼                       ▼                           ▼                   │
│   ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────────┐   │
│   │   Frontend UI   │    │     Backend     │    │   Redis Vector Database     │   │
│   │   (Port 5174)   │    │     Server      │    │         (Port 6380)         │   │
│   │   (React App)   │    │    (FastAPI)    │    │      (Vector Storage)       │   │
│   └─────────────────┘    └─────────────────┘    └─────────────────────────────┘   │
│                                   │                           │                   │
│                                   │                           │                   │
│                                   ▼                           ▼                   │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │                             RAG PIPELINE                                    │  │
│  │                                                                             │  │
│  │  ┌───────────────────┐ ┌─────────────────────┐ ┌─────────────────────────┐  │  │
│  │  │ Retriever Service │ │TEI Embedding Service│ │  TEI Reranking Service  │  │  │
│  │  │                   │ │                     │ │                         │  │  │
│  │  │   (Port 7001)     │ │    (Port 18091)     │ │      (Port 18809)       │  │  │
│  │  │                   │ │                     │ │                         │  │  │
│  │  │ • Vector Search   │ │ • Text Embedding    │ │ • Document Reranking    │  │  │
│  │  │ • Similarity      │ │ • BGE Model         │ │ • Relevance Scoring     │  │  │
│  │  │   Matching        │ │ • CPU Inference     │ │ • CPU Inference         │  │  │
│  │  └───────────────────┘ └─────────────────────┘ └─────────────────────────┘  │  │
│  │            │                      │                         │               │  │
│  │            │                      │                         │               │  │
│  │            ▼                      ▼                         ▼               │  │
│  │  ┌───────────────────────────────────────────────────────────────────────┐  │  │
│  │  │                           vLLM Service                                │  │  │
│  │  │                           (Port 18009)                                │  │  │
│  │  │                                                                       │  │  │
│  │  │                  • High-Performance LLM Inference                     │  │  │
│  │  │                  • AMD GPU Acceleration (ROCm)                        │  │  │
│  │  │                  • Qwen2.5-7B-Instruct Model                          │  │  │
│  │  │                  • Optimized for Throughput & Latency                 │  │  │
│  │  │                  • Tensor Parallel Support                            │  │  │
│  │  └───────────────────────────────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────────────────────────┘  │
│                                      │                                            │
│                                      │                                            │
│                                      ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │                            DATA PIPELINE                                    │  │
│  │                                                                             │  │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────┐  │  │
│  │  │   Dataprep      │    │   Model Cache   │    │   Document Storage      │  │  │
│  │  │   Service       │    │   (./data)      │    │   (Redis Vector DB)     │  │  │
│  │  │   (Port 18104)  │    │                 │    │                         │  │  │
│  │  │                 │    │ • Downloaded    │    │ • Vector Embeddings     │  │  │
│  │  │ • Document      │    │   Models        │    │ • Metadata Index        │  │  │
│  │  │   Processing    │    │ • Model Weights │    │ • Full-Text Search      │  │  │
│  │  │ • Text          │    │ • Cache Storage │    │ • Similarity Search     │  │  │
│  │  │   Processing    │    │                 │    │                         │  │  │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────────────┘
```

## Deployment Guide

### Step 1: Clone Repository
```bash
git clone https://github.com/opea-project/GenAIExamples.git
cd GenAIExamples/AgentQnA
```

### Step 2: Configure Environment
```bash
# Source environment variables
cd docker_compose/amd/gpu/rocm
source set_env_vllm.sh
```

### Step 3: Start Services
```bash
# Quick start with vLLM
./quick_start_vllm.sh

# Start monitoring
./start_monitoring.sh
```

### Step 4: Verify Deployment
```bash
# Check running containers
docker compose ps

# Test services
./quick_test_agentqna.sh
```

## Performance Evaluation

### Quick Evaluation
```bash
./quick_eval_setup.sh
./performance_evaluation.sh
```

### Comprehensive Evaluation
```bash
./performance_evaluation.sh --full
```

## Monitoring and Troubleshooting

### Access Monitoring
- Grafana: http://localhost:3000 (default: admin/admin)
- Prometheus: http://localhost:9090

### Common Issues
1. **Service Not Starting**
   - Check logs: `docker compose logs -f`
   - Verify ports are not in use
   - Check GPU access

2. **Performance Issues**
   - Monitor resource usage in Grafana
   - Adjust batch sizes
   - Check for bottlenecks

## Advanced Configuration

### Environment Variables
```bash
# Key variables in set_env_vllm.sh
export AGENTQNA_LLM_MODEL_ID="Qwen/Qwen2.5-7B-Instruct-1M"
export AGENTQNA_VLLM_SERVICE_PORT=18009
export temperature=0.7
export max_new_tokens=256
```

### Performance Tuning
1. Adjust batch size
2. Modify GPU memory allocation
3. Configure tensor parallelism

## Troubleshooting

1. **Service Not Starting**
   - Check logs for errors
   - Verify environment variables
   - Ensure proper GPU access

2. **Performance Issues**
   - Monitor resource usage
   - Adjust batch sizes
   - Check for bottlenecks

3. **Connection Problems**
   - Verify ports are open
   - Check network configuration
   - Ensure proper service endpoints

## Cleanup

To stop all services:
```bash
./run_agentqna.sh stop
```

To remove all containers and volumes:
```bash
./run_agentqna.sh cleanup
```
