# Agent Notes

This is a vanilla RawClaw/OpenClaw WhatsApp Web messaging demo. It intentionally
does not install or use NemoClaw, OpenShell, Docker, vLLM, a browser automation
stack, or any GPU container runtime.

The local model path defaults to:

```text
ollama/qwen3.6:27b
```

The OpenClaw profile is:

```text
openclaw-whatsapp
```

Use the `conference-assistant` skill for local smoke tests and mobile chat
responses. Keep answers concise and use Traditional Chinese when the user asks
in Chinese.

WhatsApp uses QR login through WhatsApp Web. There is no public webhook URL for
this repo. Link with:

```bash
./scripts/login-whatsapp.sh
```

The default access mode is pairing for direct messages and disabled for groups.
