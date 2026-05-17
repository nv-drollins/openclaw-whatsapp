# Clean Instance Prerequisites

This repo is intended to work on a fresh DGX Spark / Ubuntu host. The scripts
track and install host prerequisites where possible.

| Requirement | Why it is needed | Installed by |
|---|---|---|
| Ubuntu with `sudo` | First-time package and service setup | Manual host requirement |
| `git`, `curl`, `ca-certificates`, `lsof`, `python3`, `zstd` | Repo checkout, HTTP checks, service management, Ollama tar extraction | `scripts/install-host-prereqs.sh` |
| Node.js 22+ and npm | Native OpenClaw CLI runtime and WhatsApp Web/Baileys channel | `scripts/install-host-prereqs.sh` via `nvm` if needed |
| OpenClaw CLI | Native agent, gateway, dashboard, model config, WhatsApp channel, and skills | `scripts/install-host-prereqs.sh` via `npm install -g openclaw@latest` |
| Ollama 0.22.1 | Local model runtime on DGX Spark / GB10 | `scripts/install-ollama.sh` |
| `qwen3.6:27b` Ollama model | Default local model for this OpenClaw WhatsApp template | `scripts/ensure-model.sh` |
| WhatsApp account | Account linked by QR code for inbound/outbound messages | Manual |
| Outbound internet access | WhatsApp Web session and model/plugin downloads | Manual network requirement |
| Browser or SSH tunnel | To open the OpenClaw dashboard from another machine | Manual |

Optional:

- Dedicated WhatsApp number, recommended for conference demos.
- `WHATSAPP_ALLOW_FROM` and `WHATSAPP_GROUP_ALLOW_FROM` for allowlist-based demos.
- `WHATSAPP_SELF_CHAT_MODE=true` if using a personal-number self-chat flow.

Not required for this OpenClaw-only version:

- Public HTTPS webhook URL
- LINE channel credentials
- NemoClaw
- OpenShell
- Docker
- NVIDIA Container Toolkit
- vLLM
- Hugging Face token
- Attached display
