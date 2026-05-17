#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=openclaw-env.sh
. "$SCRIPT_DIR/openclaw-env.sh"
# shellcheck source=load-whatsapp-env.sh
. "$SCRIPT_DIR/load-whatsapp-env.sh"

PROFILE="${OPENCLAW_PROFILE:-openclaw-whatsapp}"
ACCOUNT="${WHATSAPP_ACCOUNT:-default}"

openclaw_require_cli

echo "Starting WhatsApp QR login for profile '$PROFILE', account '$ACCOUNT'."
echo "Scan the QR code with the WhatsApp account you want OpenClaw to use."

if [ "$ACCOUNT" = "default" ]; then
  openclaw --profile "$PROFILE" channels login --channel whatsapp
else
  openclaw --profile "$PROFILE" channels login --channel whatsapp --account "$ACCOUNT"
fi

echo "WhatsApp login flow finished. Start or restart the gateway with:"
echo "  ./scripts/start-demo.sh --no-install"
