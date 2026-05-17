#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=load-whatsapp-env.sh
. "$SCRIPT_DIR/load-whatsapp-env.sh"

RUN_INSTALL=1
RUN_AGENT_SMOKE="${OPENCLAW_RUN_AGENT_SMOKE:-0}"
RUN_LOGIN=0

usage() {
  cat <<EOF
Usage: $0 [--no-install] [--agent-smoke] [--login]

Starts the OpenClaw WhatsApp Web messaging demo:
  - installs clean-instance prerequisites when needed
  - ensures Ollama and the configured local model are available
  - validates WhatsApp access-policy configuration
  - configures native OpenClaw
  - starts the OpenClaw gateway and prints dashboard access

WhatsApp uses QR login through WhatsApp Web. Run with --login when you are in
front of the console and ready to scan the QR code.

Options:
  --no-install   Skip prerequisite installation checks.
  --agent-smoke  Run a native OpenClaw prompt against the conference assistant skill.
  --login        Run WhatsApp QR login after configuring OpenClaw.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-install) RUN_INSTALL=0 ;;
    --agent-smoke) RUN_AGENT_SMOKE=1 ;;
    --login) RUN_LOGIN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

echo "[1/6] Checking host prerequisites"
if [ "$RUN_INSTALL" -eq 1 ]; then
  "$SCRIPT_DIR/install-host-prereqs.sh"
else
  echo "Skipping install step"
fi

echo "[2/6] Ensuring local Ollama model"
"$SCRIPT_DIR/ensure-model.sh"

echo "[3/6] Checking WhatsApp channel configuration"
"$SCRIPT_DIR/check-whatsapp-config.sh"

echo "[4/6] Configuring native OpenClaw"
"$SCRIPT_DIR/setup-openclaw.sh"

if [ "$RUN_LOGIN" = "1" ]; then
  echo "[login] WhatsApp QR login"
  "$SCRIPT_DIR/login-whatsapp.sh"
fi

if [ "$RUN_AGENT_SMOKE" = "1" ]; then
  echo "[5/6] OpenClaw agent smoke"
  "$SCRIPT_DIR/run-openclaw-smoke.sh"
fi

echo "[6/6] OpenClaw gateway and WhatsApp listener"
"$SCRIPT_DIR/start-openclaw-gateway.sh"
"$SCRIPT_DIR/show-dashboard.sh"

cat <<EOF

WhatsApp setup reminder:
  If the account is not linked yet, run:
    ./scripts/login-whatsapp.sh

  The gateway must be running for inbound WhatsApp messages to be handled.

Pairing commands:
  openclaw --profile "${OPENCLAW_PROFILE:-openclaw-whatsapp}" pairing list whatsapp
  openclaw --profile "${OPENCLAW_PROFILE:-openclaw-whatsapp}" pairing approve whatsapp <CODE>

Stop the demo with:
  ./scripts/stop-demo.sh
EOF
