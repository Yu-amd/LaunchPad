# AgentQnA vLLM Tutorial

This guide provides a comprehensive tutorial on using vLLM as the LLM serving framework for AgentQnA. vLLM offers high-performance LLM inference capabilities, making it an excellent choice for AgentQnA deployments.

## Table of Contents

1. [Introduction to vLLM](#introduction-to-vllm)
2. [Setting Up AgentQnA with vLLM](#setting-up-agentqna-with-vllm)
3. [Configuration Details](#configuration-details)
4. [Running Services](#running-services)
5. [Testing the Setup](#testing-the-setup)
6. [Performance Optimization](#performance-optimization)
7. [Troubleshooting](#troubleshooting)

## Introduction to vLLM

vLLM is a high-performance LLM serving framework that provides:
- Efficient batch processing
- Dynamic batching
- Multi-GPU support
- Optimized memory usage
- High throughput for LLM inference

## Setting Up AgentQnA with vLLM

To use vLLM with AgentQnA, follow these steps:

1. **Clone the Repository**
```bash
git clone https://github.com/opea-project/GenAIExamples.git
cd GenAIExamples/AgentQnA
```

2. **Configure Environment**
```bash
# Source vLLM environment
cd docker_compose/amd/gpu/rocm
source set_env_vllm.sh
```

3. **Start Services**
```bash
./quick_start_vllm.sh
```

## Configuration Details

The main configuration parameters in `set_env_vllm.sh` are:

- **Model Settings**
  - `AGENTQNA_LLM_MODEL_ID`: Specifies the LLM model to use
  - `AGENTQNA_HUGGINGFACEHUB_API_TOKEN`: Required for model access

- **Service Ports**
  - `AGENTQNA_VLLM_SERVICE_PORT`: Main vLLM service port
  - `WORKER_RAG_AGENT_PORT`: RAG agent port
  - `WORKER_SQL_AGENT_PORT`: SQL agent port
  - `SUPERVISOR_REACT_AGENT_PORT`: React agent port

- **Agent Parameters**
  - `temperature`: Controls randomness in responses
  - `max_new_tokens`: Maximum tokens in responses
  - `recursion_limit_worker`: Worker recursion limit
  - `recursion_limit_supervisor`: Supervisor recursion limit

## Running Services

To run AgentQnA with vLLM:

1. **Start Services**
```bash
./quick_start_vllm.sh
```

2. **Monitor Services**
```bash
./start_monitoring.sh
```

3. **Test Services**
```bash
./quick_test_agentqna.sh
```

## Testing the Setup

You can test the services using the quick test script:
```bash
./quick_test_agentqna.sh
```

This will test:
- RAG Agent functionality
- SQL Agent functionality
- React Agent functionality

## Performance Optimization

To optimize performance:

1. **Adjust Batch Size**
   - Modify batch size in vLLM configuration
   - Use dynamic batching for better efficiency

2. **Memory Management**
   - Adjust shared memory size in compose file
   - Use appropriate dtype (float16 recommended)

3. **GPU Configuration**
   - Ensure proper ROCm device configuration
   - Use tensor parallelism for multi-GPU setups

## Troubleshooting

Common issues and solutions:

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
