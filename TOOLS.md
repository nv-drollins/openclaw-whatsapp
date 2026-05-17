# Tool Guidance

This repo is a vanilla OpenClaw WhatsApp Web messaging-channel demo.

- Use `scripts/run-openclaw-smoke.sh` to test the local model and `conference-assistant` skill.
- Use `scripts/check-whatsapp-config.sh` to validate WhatsApp policy settings.
- Use `scripts/login-whatsapp.sh` when ready to scan the WhatsApp QR code.
- WhatsApp messages are received through the OpenClaw gateway's WhatsApp Web session, not through a public webhook.
- Do not add NemoClaw, OpenShell, Docker, vLLM, or Hugging Face requirements.
