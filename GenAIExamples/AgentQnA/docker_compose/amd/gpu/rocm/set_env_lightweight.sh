#!/bin/bash

# =====================
# AGENTQNA LIGHTWEIGHT ENV VARS
# =====================

# Host IP
export HOST_IP=$(hostname -I | awk '{print $1}')

# Model and HuggingFace
export AGENTQNA_LLM_MODEL_ID="teknium/OpenHermes-2.5-Mistral-7B"  # or your model
export AGENTQNA_HUGGINGFACEHUB_API_TOKEN=""  # Fill in your HF token

# Ports (minimal set for lightweight)
export AGENTQNA_TGI_SERVICE_PORT=18008
export WORKER_RAG_AGENT_PORT=7001
export WORKER_SQL_AGENT_PORT=7002
export SUPERVISOR_REACT_AGENT_PORT=7003

# Toolset and Workdir
export TOOLSET_PATH="/root/GenAIExamples/AgentQnA/tools"  # Set to your tools dir
export WORKDIR="/root/GenAIExamples/AgentQnA"  # Set to your workspace root

# AgentQnA Backend Endpoint
export AGENTQNA_BACKEND_SERVICE_ENDPOINT="http://localhost:${AGENTQNA_TGI_SERVICE_PORT}/v1/agentqna"

# Agent/LLM Parameters
export temperature=0.7
export max_new_tokens=256
export recursion_limit_worker=3
export recursion_limit_supervisor=3

# External Service URLs
export CRAG_SERVER="http://localhost:8080"
export WORKER_AGENT_URL="http://localhost:${WORKER_RAG_AGENT_PORT}/v1/chat/completions"
export SQL_AGENT_URL="http://localhost:${WORKER_SQL_AGENT_PORT}/v1/chat/completions"

# LangChain/Tracing
export LANGCHAIN_API_KEY=""
export LANGCHAIN_TRACING_V2=""

# Retrieval Tool URL (if used)
export RETRIEVAL_TOOL_URL=""
