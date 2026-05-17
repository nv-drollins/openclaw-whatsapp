# OpenClaw WhatsApp Demo

Vanilla RawClaw/OpenClaw setup for running a local Ollama-backed assistant over
WhatsApp. The main flow is for an attendee to link their own WhatsApp account to
their own Spark, then chat with OpenClaw through WhatsApp self-chat.

This version uses OpenClaw's WhatsApp Web channel, so it does not need a public
webhook URL. The Spark only needs outbound internet access for the WhatsApp Web
session.

The default local model is:

```text
ollama/qwen3.6:27b
```

See [PREREQUISITES.md](PREREQUISITES.md) for the clean-instance requirements
ledger.

## Primary Flow

Use this for a conference attendee with their own Spark and their own WhatsApp
number.

```text
Attendee's phone number
        |
        | scan QR code
        v
OpenClaw on the attendee's Spark
        |
        | WhatsApp self-chat
        v
Attendee messages themselves and receives local OpenClaw responses
```

The attendee's WhatsApp number is both:

- the linked WhatsApp Web account OpenClaw uses to send replies
- the only number allowed to talk to that local OpenClaw instance

## Quick Start

Run these commands on the Spark or Ubuntu host:

```bash
git clone https://github.com/nv-drollins/openclaw-whatsapp.git
cd openclaw-whatsapp
chmod +x install.sh scripts/*.sh
cp .env.example .env
```

Edit one line in `.env` and replace the placeholder with the attendee's
WhatsApp number in international format:

```bash
WHATSAPP_ALLOW_FROM=+15551234567
```

Then install and start:

```bash
./install.sh
```

This demo was created and tested with OpenClaw CLI `2026.5.12`. The installer
uses that version by default. To intentionally test a different OpenClaw
release, pass it through the install command:

```bash
OPENCLAW_CLI_VERSION=2026.5.12 ./install.sh
```

Use `OPENCLAW_CLI_VERSION=latest ./install.sh` only when validating the latest
OpenClaw release.

Link WhatsApp with a QR code:

```bash
./scripts/login-whatsapp.sh
```

Scan the QR code with the same WhatsApp account/number you put in
`WHATSAPP_ALLOW_FROM`.

Start or restart the gateway:

```bash
./scripts/start-demo.sh --no-install
```

Open WhatsApp on the phone, open the **Message yourself** chat, and send:

```text
Explain this local AI demo in Traditional Chinese in three bullets.
```

## Default `.env`

The provided `.env.example` is set up for the personal Spark/self-chat flow:

```bash
WHATSAPP_ACCOUNT=default
WHATSAPP_DM_POLICY=allowlist
WHATSAPP_ALLOW_FROM=+15551234567
WHATSAPP_SELF_CHAT_MODE=true
WHATSAPP_GROUP_POLICY=disabled
```

The only required edit for the attendee flow is `WHATSAPP_ALLOW_FROM`.

## What You Get

- Native OpenClaw on the host, with no NemoClaw/OpenShell sandbox
- WhatsApp Web / Baileys channel setup
- Local Ollama model setup
- A small `conference-assistant` skill for bilingual booth/demo chats
- Self-chat support for personal WhatsApp accounts
- Start, stop, QR-login, status, dashboard, and smoke-test scripts

## WhatsApp Requirements

You need:

- A WhatsApp account to link by QR code
- The attendee's WhatsApp number in international format
- Outbound internet access from the Spark
- The OpenClaw gateway running during the demo

You do not need:

- A public HTTPS webhook
- LINE channel credentials
- Twilio or the official WhatsApp Business API

OpenClaw's current WhatsApp channel is WhatsApp Web based. The gateway owns the
linked session and reconnect loop.

## Alternate Flow: Shared Demo Number

If you want one shared demo WhatsApp number that multiple attendees message,
use pairing mode instead of self-chat:

```bash
WHATSAPP_DM_POLICY=pairing
WHATSAPP_ALLOW_FROM=
WHATSAPP_SELF_CHAT_MODE=false
WHATSAPP_GROUP_POLICY=disabled
```

Then link the dedicated demo phone with:

```bash
./scripts/login-whatsapp.sh
```

When attendees message that number, approve each pairing request:

```bash
openclaw --profile openclaw-whatsapp pairing list whatsapp
openclaw --profile openclaw-whatsapp pairing approve whatsapp <CODE>
```

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

| Variable | Default | Purpose |
|---|---:|---|
| `OPENCLAW_CLI_VERSION` | `2026.5.12` | OpenClaw CLI npm package version installed by the prereq script |
| `OPENCLAW_PROFILE` | `openclaw-whatsapp` | Native OpenClaw profile name |
| `OPENCLAW_OLLAMA_MODEL` | `qwen3.6:27b` | Ollama model to pull and use |
| `OPENCLAW_MODEL_REF` | `ollama/${OPENCLAW_OLLAMA_MODEL}` | OpenClaw model id |
| `OPENCLAW_GATEWAY_PORT` | `18796` | Dashboard/gateway port |
| `OPENCLAW_GATEWAY_BIND` | `loopback` | Gateway bind mode; use `lan` only on trusted networks |
| `WHATSAPP_ACCOUNT` | `default` | Optional OpenClaw WhatsApp account id |
| `WHATSAPP_DM_POLICY` | `allowlist` | Direct-message access policy |
| `WHATSAPP_ALLOW_FROM` | `+15551234567` | Attendee phone number to allow |
| `WHATSAPP_SELF_CHAT_MODE` | `true` | Self-chat helper mode for personal-number demos |
| `WHATSAPP_GROUP_POLICY` | `disabled` | Group-chat sender policy |
| `WHATSAPP_GROUP_ALLOW_FROM` | unset | Optional comma-separated or JSON group sender allowlist |
| `WHATSAPP_GROUPS` | unset | Optional comma-separated or JSON group allowlist |
| `WHATSAPP_MEDIA_MAX_MB` | `50` | Inbound/outbound media cap |
| `WHATSAPP_SEND_READ_RECEIPTS` | `true` | Whether accepted inbound messages send read receipts |
| `WHATSAPP_REACTION_LEVEL` | `minimal` | Reaction behavior: `off`, `ack`, `minimal`, or `extensive` |

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
