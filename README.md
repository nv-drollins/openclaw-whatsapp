# OpenClaw WhatsApp Demo

Vanilla RawClaw/OpenClaw setup for running a local Ollama-backed assistant over
WhatsApp. This version uses OpenClaw's WhatsApp Web channel, so it does not
need a public webhook URL. The Spark only needs outbound internet access for
the WhatsApp Web session.

The default local model is:

```text
ollama/qwen3.6:27b
```

See [PREREQUISITES.md](PREREQUISITES.md) for the clean-instance requirements
ledger.

## What You Get

- Native OpenClaw on the host, with no NemoClaw/OpenShell sandbox
- WhatsApp Web / Baileys channel setup
- Local Ollama model setup
- A small `conference-assistant` skill for bilingual booth/demo chats
- Pairing-based direct-message access by default
- Start, stop, QR-login, status, dashboard, and smoke-test scripts

## WhatsApp Requirements

You need:

- A WhatsApp account to link by QR code
- Preferably a dedicated demo number
- Outbound internet access from the Spark
- The OpenClaw gateway running during the demo

You do not need:

- A public HTTPS webhook
- LINE channel credentials
- Twilio or the official WhatsApp Business API

OpenClaw's current WhatsApp channel is WhatsApp Web based. The gateway owns the
linked session and reconnect loop.

## Quick Start

Run these commands on the Spark or Ubuntu host:

```bash
git clone https://github.com/nv-drollins/openclaw-whatsapp.git
cd openclaw-whatsapp
chmod +x install.sh scripts/*.sh
cp .env.example .env
./install.sh
```

For a simple conference demo, the default `.env` values are usually fine:

```bash
WHATSAPP_DM_POLICY=pairing
WHATSAPP_GROUP_POLICY=disabled
WHATSAPP_ACCOUNT=default
```

Only edit `.env` if you want to change the model, gateway port, or access
policy.

Then link WhatsApp with a QR code:

```bash
./scripts/login-whatsapp.sh
```

Start or restart the gateway:

```bash
./scripts/start-demo.sh --no-install
```

## Demo Flow

1. Start the demo:

```bash
./scripts/start-demo.sh
```

2. Link the WhatsApp account:

```bash
./scripts/login-whatsapp.sh
```

3. Message the linked WhatsApp number from another phone.

4. If pairing mode is enabled, approve the request:

```bash
openclaw --profile openclaw-whatsapp pairing list whatsapp
openclaw --profile openclaw-whatsapp pairing approve whatsapp <CODE>
```

5. Try a conference prompt from WhatsApp:

```text
Explain this local AI demo in Traditional Chinese in three bullets.
```

## Access Policies

The default is pairing mode:

```bash
WHATSAPP_DM_POLICY=pairing
```

That is safer for a conference because unknown direct-message senders request
access first. If you know exactly who should use the demo, use allowlist mode:

```bash
WHATSAPP_DM_POLICY=allowlist
WHATSAPP_ALLOW_FROM=+15551234567,+886912345678
```

Open mode is possible, but it should only be used intentionally:

```bash
WHATSAPP_DM_POLICY=open
WHATSAPP_ALLOW_FROM=*
```

Groups are disabled by default. If you enable groups, use allowlists unless you
are intentionally running a wide-open room demo.

## Day-2 Commands

Start or repair the full demo:

```bash
./scripts/start-demo.sh
```

Start and run QR login in one flow:

```bash
./scripts/start-demo.sh --login
```

Link or relink WhatsApp:

```bash
./scripts/login-whatsapp.sh
```

Check channel status:

```bash
./scripts/show-whatsapp-status.sh
```

Stop the OpenClaw gateway:

```bash
./scripts/stop-demo.sh
```

Run a native OpenClaw agent smoke test:

```bash
./scripts/run-openclaw-smoke.sh
```

Show the dashboard URL and token:

```bash
./scripts/show-dashboard.sh
```

## Configuration

The default `.env` copied from `.env.example` is ready for a first run. Edit it
only when you want to change one of these settings:

| Variable | Default | Purpose |
|---|---:|---|
| `OPENCLAW_PROFILE` | `openclaw-whatsapp` | Native OpenClaw profile name |
| `OPENCLAW_OLLAMA_MODEL` | `qwen3.6:27b` | Ollama model to pull and use |
| `OPENCLAW_MODEL_REF` | `ollama/${OPENCLAW_OLLAMA_MODEL}` | OpenClaw model id |
| `OPENCLAW_GATEWAY_PORT` | `18796` | Dashboard/gateway port |
| `OPENCLAW_GATEWAY_BIND` | `loopback` | Gateway bind mode; use `lan` only on trusted networks |
| `WHATSAPP_ACCOUNT` | `default` | Optional OpenClaw WhatsApp account id |
| `WHATSAPP_DM_POLICY` | `pairing` | Direct-message access policy |
| `WHATSAPP_GROUP_POLICY` | `disabled` | Group-chat sender policy |
| `WHATSAPP_ALLOW_FROM` | unset | Optional comma-separated or JSON allowlist of phone numbers |
| `WHATSAPP_GROUP_ALLOW_FROM` | unset | Optional comma-separated or JSON group sender allowlist |
| `WHATSAPP_GROUPS` | unset | Optional comma-separated or JSON group allowlist |
| `WHATSAPP_MEDIA_MAX_MB` | `50` | Inbound/outbound media cap |
| `WHATSAPP_SEND_READ_RECEIPTS` | `true` | Whether accepted inbound messages send read receipts |
| `WHATSAPP_REACTION_LEVEL` | `minimal` | Reaction behavior: `off`, `ack`, `minimal`, or `extensive` |
| `WHATSAPP_SELF_CHAT_MODE` | `false` | Self-chat helper mode for personal-number demos |

## Notes

This project deliberately does not install or use NemoClaw, OpenShell, Docker,
NVIDIA Container Toolkit, vLLM, or Hugging Face credentials. Native OpenClaw
runs on the host and connects to WhatsApp through WhatsApp Web.

Current OpenClaw releases can install the WhatsApp channel on demand. If needed,
you can install it manually:

```bash
openclaw --profile openclaw-whatsapp plugins install @openclaw/whatsapp
```

Useful troubleshooting commands:

```bash
openclaw --profile openclaw-whatsapp channels status
openclaw --profile openclaw-whatsapp doctor
openclaw --profile openclaw-whatsapp logs --follow
```
