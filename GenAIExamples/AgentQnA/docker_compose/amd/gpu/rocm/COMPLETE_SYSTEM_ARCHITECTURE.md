# AgentQnA vLLM Complete System Architecture

## System Overview

AgentQnA with vLLM is a comprehensive Retrieval-Augmented Generation (RAG) system that combines document retrieval with high-performance LLM inference for agent-based applications. The system is built using a microservices architecture with Docker containers.

## Complete System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                               EXTERNAL ACCESS                                   │
│                                                                                 │
│   ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────────┐ │
│   │   Web Browser   │    │   API Clients   │    │   Monitoring Tools          │ │
│   │                 │    │                 │    │   (Grafana, Prometheus)     │ │
│   └─────────────────┘    └─────────────────┘    └─────────────────────────────┘ │
│           │                       │                           │                 │
│           │                       │                           │                 │
│           ▼                       ▼                           ▼                 │
│   ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────────┐ │
│   │   Frontend UI   │    │   Backend API   │    │   Redis Vector Database     │ │
│   │   (Port 5174)   │    │   (Port 8890)   │    │   (Port 6380)               │ │
│   │   (React App)   │    │   (FastAPI)     │    │   (Vector Storage)          │ │
│   └─────────────────┘    └─────────────────┘    └─────────────────────────────┘ │
│                                   │                           │                 │
│                                   │                           │                 │
│                                   ▼                           ▼                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐│
│  │                           RAG PIPELINE                                      ││
│  │                                                                             ││
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────┐  ││
│  │  │   Retriever     │    │   TEI Embedding │    │   TEI Reranking         │  ││
│  │  │   Service       │    │   Service       │    │   Service               │  ││
│  │  │   (Port 7001)   │    │   (Port 18091)  │    │   (Port 18809)          │  ││
│  │  │                 │    │                 │    │                         │  ││
│  │  │ • Vector Search │    │ • Text Embedding│    │ • Document Reranking    │  ││
│  │  │ • Similarity    │    │ • BGE Model     │    │ • Relevance Scoring     │  ││
│  │  │   Matching      │    │ • CPU Inference │    │ • CPU Inference         │  ││
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────────┘  ││
│  │           │                       │                       │                 ││
│  │           │                       │                       │                 ││
│  │           ▼                       ▼                       ▼                 ││
│  │  ┌─────────────────────────────────────────────────────────────────────────┐││
│  │  │                    vLLM Service                                         │││
│  │  │                    (Port 18009)                                         │││
│  │  │                                                                         │││
│  │  │  • High-Performance LLM Inference                                       │││
│  │  │  • AMD GPU Acceleration (ROCm)                                          │││
│  │  │  • Qwen2.5-7B-Instruct Model                                            │││
│  │  │  • Optimized for Throughput & Latency                                   │││
│  │  │  • Tensor Parallel Support                                              │││
│  │  └─────────────────────────────────────────────────────────────────────────┘││
│  └─────────────────────────────────────────────────────────────────────────────┘│
│                                   │                                             │
│                                   │                                             │
│                                   ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────┐│
│  │                           DATA PIPELINE                                     ││
│  │                                                                             ││
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────┐  ││
│  │  │   Dataprep      │    │   Model Cache   │    │   Document Storage      │  ││
│  │  │   Service       │    │   (./data)      │    │   (Redis Vector DB)     │  ││
│  │  │   (Port 18104)  │    │                 │    │                         │  ││
│  │  │                 │    │ • Downloaded    │    │ • Vector Embeddings     │  ││
│  │  │ • Document      │    │   Models        │    │ • Metadata Index        │  ││
│  │  │   Processing    │    │ • Model Weights │    │ • Full-Text Search      │  ││
│  │  │ • Text          │    │ • Cache Storage │    │ • Similarity Search     │  ││
│  │  │   Processing    │    │ • Shared Volume │    │ • Redis Stack           │  ││
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────────┘  ││
│  └─────────────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Service Details

### Frontend Layer
- **Frontend UI** (Port 5174): React-based web interface for agent interactions
- **Backend API** (Port 8890): FastAPI server handling agent requests

### RAG Pipeline
- **Retriever Service** (Port 7001): Vector search and document retrieval
- **TEI Embedding Service** (Port 18091): Text embedding generation
- **TEI Reranking Service** (Port 18809): Document reranking

### LLM Service
- **vLLM Service** (Port 18009): High-performance LLM inference with:
  - AMD GPU Acceleration (ROCm)
  - Qwen2.5-7B-Instruct Model
  - Optimized for Throughput & Latency
  - Tensor Parallel Support

### Data Pipeline
- **Dataprep Service** (Port 18104): Document processing and preparation
- **Model Cache**: Local storage for downloaded models
- **Redis Vector Database**: Vector storage and similarity search

## Key Components

### vLLM Service
- High-performance LLM inference
- AMD GPU acceleration using ROCm
- Supports Qwen2.5-7B-Instruct model
- Optimized for throughput and latency
- Tensor parallel support for multi-GPU setups

### RAG Pipeline
- Vector-based document retrieval
- Text embedding generation
- Document reranking
- CPU-based inference for embedding services

### Data Storage
- Redis Vector Database for vector storage
- Redis Stack for caching and indexing
- Local model cache for fast access

## Configuration Points

### Environment Variables
- `AGENTQNA_LLM_MODEL_ID`: Specifies the LLM model to use
- `AGENTQNA_VLLM_SERVICE_PORT`: Main vLLM service port
- `temperature`: Controls randomness in responses
- `max_new_tokens`: Maximum tokens in responses
- `recursion_limit_worker`: Worker recursion limit
- `recursion_limit_supervisor`: Supervisor recursion limit

### Service Ports
- Frontend: 5174
- Backend API: 8890
- vLLM Service: 18009
- Retriever Service: 7001
- TEI Services: 18091, 18809
- Dataprep Service: 18104
- Redis: 6380

## Monitoring and Logging
- Prometheus for metrics collection
- Grafana for visualization
- Docker logs for service debugging
- Built-in performance monitoring

## Security Considerations
- Environment variable isolation
- Container security policies
- Network isolation between services
- API authentication and authorization
- Model access control

## Performance Optimization
- Dynamic batching in vLLM
- Memory optimization
- GPU utilization monitoring
- CPU/GPU load balancing
- Cache optimization

## Deployment Considerations
- Resource allocation
- Network configuration
- Storage optimization
- Backup strategies
- Update procedures

## Troubleshooting Guide

### Common Issues
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

### Debugging Steps
1. Check Docker logs
2. Monitor resource usage
3. Verify service connectivity
4. Check configuration files
5. Review error messages

## Cleanup Procedures

To properly clean up the system:
```bash
# Stop all services
./run_agentqna.sh stop

# Remove containers and volumes
./run_agentqna.sh cleanup

# Clear cache
rm -rf ./data/*
```

## Best Practices

### Performance
- Use appropriate batch sizes
- Monitor GPU utilization
- Optimize memory usage
- Implement proper caching

### Security
- Use secure environment variables
- Implement proper authentication
- Regular security updates
- Monitor access logs

### Maintenance
- Regular backups
- Monitor system health
- Update dependencies
- Test deployments

## Future Enhancements

### Planned Features
- Enhanced monitoring capabilities
- Additional LLM models support
- Improved caching mechanisms
- Advanced security features
- Better resource optimization

### Community Contributions
- Performance optimizations
- New model integrations
- Additional features
- Bug fixes and improvements

## Support and Resources

For support and resources:
- GitHub Issues
- Documentation
- Community forums
- Technical support
