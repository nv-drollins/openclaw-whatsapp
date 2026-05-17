#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=resolve-demo-root.sh
. "$SCRIPT_DIR/resolve-demo-root.sh"
ROOT="$(resolve_demo_root "$SCRIPT_DIR")"
# shellcheck source=openclaw-env.sh
. "$SCRIPT_DIR/openclaw-env.sh"
# shellcheck source=load-whatsapp-env.sh
. "$SCRIPT_DIR/load-whatsapp-env.sh"

PROFILE="${OPENCLAW_PROFILE:-openclaw-whatsapp}"
MODEL_REF="${OPENCLAW_MODEL_REF:-ollama/${OPENCLAW_OLLAMA_MODEL:-qwen3.6:27b}}"
SESSION="${OPENCLAW_SMOKE_SESSION:-whatsapp-conference-smoke}"
LOG_FILE="$ROOT/logs/openclaw-smoke.json"

mkdir -p "$ROOT/logs"
openclaw_require_cli

openclaw --profile "$PROFILE" agent \
  --local \
  --session-id "$SESSION" \
  --model "$MODEL_REF" \
  --timeout "${OPENCLAW_AGENT_TIMEOUT:-300}" \
  --message "Use the conference-assistant skill to write a short welcome for partners visiting an OpenClaw demo booth in Taiwan. Include English and Traditional Chinese." \
  --json > "$LOG_FILE"

python3 - "$LOG_FILE" <<'PY'
import json
import sys

path = sys.argv[1]
data = json.load(open(path, encoding="utf-8"))
texts = [p.get("text", "") for p in data.get("payloads", [])]
text = "\n".join(texts).strip()
print(text)

if len(text) < 20:
    raise SystemExit("OpenClaw smoke response was unexpectedly short")
if not any(marker in text for marker in ["歡迎", "伙伴", "夥伴", "Taiwan", "OpenClaw"]):
    raise SystemExit("OpenClaw smoke response did not look like a conference welcome")
PY
