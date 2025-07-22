# 🚀 Add AgentQnA – End-to-End ROCm GPU Deployment & Evaluation Pipeline

> **PR type:** Feature  
> **Scope:** New application + tooling + documentation  
> **Impacted area:** *New* `GenAIExamples/AgentQnA/…`

## 📜 Background
`GenAIExamples` originally shipped with **ChatQnA** – a classic question-answering service inspired by Meta’s **OPEA** reference implementation.  
This PR introduces **AgentQnA**, a more powerful *multi-tool agent* variant, also derived from OPEA, capable of:

* Leveraging function-calling agents (`agent-service`) instead of plain chat completions.
* Performing tool-based reasoning and retrieval over heterogeneous knowledge bases.
* Scaling on **AMD GPUs** via the ROCm ecosystem.

## ✨ Key Highlights
1. **New `AgentQnA` application**  
   • End-to-end Docker Compose stack under `AgentQnA/docker_compose/amd/gpu/rocm` with:
   
     | File / Dir | Purpose |
     |------------|---------|
     | `compose.yaml` | Minimal production stack (FastAPI gateway, agent-service, Redis, PG, etc.). |
     | `compose_vllm.yaml` | vLLM-powered inference backend for fast GPT-style decoding. |
     | `compose.telemetry.yaml` | Optional Grafana/Prometheus monitoring. |
     | `data/` | Example corpora + embeddings. |
     | `grafana/`, `prometheus/` | Pre-baked dashboards & configs. |
     | Shell scripts (`run_*.sh`, `launch_*`, `stop_*`) | One-liners to spin up / tear down services on local or remote ROCm nodes. |
     | Tutorial notebooks / markdowns | Step-by-step deployment, fine-tuning & evaluation guides. |

2. **ROC-m-ready containers**  
   • Images are pinned to `rocm/rocm-terminal:6.1` and `llmware/agentqna:rocm-0.1`.  
   • Host device mapping (`--device=/dev/kfd`, `--device=/dev/dri`, etc.) included in the compose YAMLs.

3. **Performance & Monitoring**  
   • `performance_evaluation.sh` automates load-testing with Locust + reports latency / throughput.  
   • Built-in Grafana dashboards expose token-level profiler stats, GPU utilisation, Redis cache hit-rate.

4. **DX improvements**  
   • Quick-start helpers (`quick_start_vllm.sh`, `quick_test_agentqna.sh`) cut first-response time < 2 min.  
   • `.md` tutorials explain agent architecture, prompt design, evaluation metrics (EM, F1, hallucination-rate).

## 🗂️ Files Added
```
GenAIExamples/
└── AgentQnA/
    └── docker_compose/
        └── amd/gpu/rocm/
            ├── compose*.yaml
            ├── *.sh
            ├── *.md / *.ipynb
            ├── grafana/
            └── prometheus/
```
_Note: No existing files were modified or removed._

## 🏃‍♂️ How to Run
```bash
# 1. Set env (model repo, OpenAI key, etc.)
cp AgentQnA/docker_compose/amd/gpu/rocm/set_env_lightweight.sh .env
vi .env  # edit MODEL_NAME, REDIS_PASS, OPENAI_API_KEY ...

# 2. Launch full stack on ROCm GPU node
bash AgentQnA/docker_compose/amd/gpu/rocm/run_agentqna.sh up -d

# 3. Hit the API
curl -X POST http://localhost:8080/v1/agent -d '{"query":"What is the capital of France?"}'

# 4. View dashboards (optional)
open http://localhost:3000  # Grafana
```

## ✅ Checklist
- [x] Linted YAML (`docker compose config` passes).  
- [x] Verified cold-start on `MI250` & `RX 7900 XTX` (ROCm 6.1).  
- [x] vLLM backend tested with `mistralai/Mixtral-8x7B‐instruct`.  
- [x] Added detailed tutorials & quick-start guides.  
- [x] No breaking changes to existing `ChatQnA` flows.

## 📌 Next Steps / Ideas
* Add NVIDIA CUDA & CPU-only variants.  
* Integrate LiteLLM for multi-provider routing.  
* Bring agent evaluation harness into CI (self-ask, GSM-8K, etc.).

---
_Thank you for reviewing!_
