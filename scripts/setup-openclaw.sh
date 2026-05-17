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
OLLAMA_MODEL="${OPENCLAW_OLLAMA_MODEL:-qwen3.6:27b}"
MODEL_REF="${OPENCLAW_MODEL_REF:-ollama/${OLLAMA_MODEL}}"
PORT="${OPENCLAW_GATEWAY_PORT:-18796}"
BIND="${OPENCLAW_GATEWAY_BIND:-loopback}"
WHATSAPP_DM_POLICY="${WHATSAPP_DM_POLICY:-pairing}"
WHATSAPP_GROUP_POLICY="${WHATSAPP_GROUP_POLICY:-disabled}"
WHATSAPP_MEDIA_MAX_MB="${WHATSAPP_MEDIA_MAX_MB:-50}"
WHATSAPP_SEND_READ_RECEIPTS="${WHATSAPP_SEND_READ_RECEIPTS:-true}"
WHATSAPP_REACTION_LEVEL="${WHATSAPP_REACTION_LEVEL:-minimal}"
WHATSAPP_SELF_CHAT_MODE="${WHATSAPP_SELF_CHAT_MODE:-false}"

openclaw_require_cli

expand_path() {
  case "$1" in
    "~") printf '%s\n' "$HOME" ;;
    "~/"*) printf '%s/%s\n' "$HOME" "${1#\~/}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

read_config_value() {
  local config_path="$1"
  local dotted_path="$2"

  [ -f "$config_path" ] || return 0
  python3 - "$config_path" "$dotted_path" <<'PY'
import json
import sys

config_path, dotted_path = sys.argv[1:3]
try:
    with open(config_path, encoding="utf-8") as f:
        value = json.load(f)
    for part in dotted_path.split("."):
        value = value[part]
except Exception:
    sys.exit(0)
if value is None:
    sys.exit(0)
print(value)
PY
}

write_gateway_token() {
  local config_path="$1"
  local token="$2"

  python3 - "$config_path" "$token" <<'PY'
import json
import sys

config_path, token = sys.argv[1:3]
with open(config_path, encoding="utf-8") as f:
    data = json.load(f)
gateway = data.setdefault("gateway", {})
auth = gateway.setdefault("auth", {})
auth["mode"] = "token"
auth["token"] = token
with open(config_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY
}

patch_whatsapp_config() {
  local config_path="$1"

  WHATSAPP_DM_POLICY="$WHATSAPP_DM_POLICY" \
  WHATSAPP_GROUP_POLICY="$WHATSAPP_GROUP_POLICY" \
  WHATSAPP_MEDIA_MAX_MB="$WHATSAPP_MEDIA_MAX_MB" \
  WHATSAPP_SEND_READ_RECEIPTS="$WHATSAPP_SEND_READ_RECEIPTS" \
  WHATSAPP_REACTION_LEVEL="$WHATSAPP_REACTION_LEVEL" \
  WHATSAPP_SELF_CHAT_MODE="$WHATSAPP_SELF_CHAT_MODE" \
  WHATSAPP_ALLOW_FROM="${WHATSAPP_ALLOW_FROM:-}" \
  WHATSAPP_GROUP_ALLOW_FROM="${WHATSAPP_GROUP_ALLOW_FROM:-}" \
  WHATSAPP_GROUPS="${WHATSAPP_GROUPS:-}" \
  python3 - "$config_path" <<'PY'
import json
import os
import sys

config_path = sys.argv[1]

def env_list(name):
    raw = os.environ.get(name, "").strip()
    if not raw:
        return None
    if raw.startswith("["):
        value = json.loads(raw)
        if not isinstance(value, list):
            raise SystemExit(f"{name} must be a JSON array or comma-separated list")
        return value
    return [item.strip() for item in raw.split(",") if item.strip()]

with open(config_path, encoding="utf-8") as f:
    data = json.load(f)

channels = data.setdefault("channels", {})
whatsapp = channels.setdefault("whatsapp", {})
whatsapp["enabled"] = True
whatsapp["dmPolicy"] = os.environ.get("WHATSAPP_DM_POLICY", "pairing")
whatsapp["groupPolicy"] = os.environ.get("WHATSAPP_GROUP_POLICY", "disabled")
whatsapp["mediaMaxMb"] = int(os.environ.get("WHATSAPP_MEDIA_MAX_MB", "50"))
whatsapp["sendReadReceipts"] = os.environ.get("WHATSAPP_SEND_READ_RECEIPTS", "true").lower() == "true"
whatsapp["reactionLevel"] = os.environ.get("WHATSAPP_REACTION_LEVEL", "minimal")
whatsapp["selfChatMode"] = os.environ.get("WHATSAPP_SELF_CHAT_MODE", "false").lower() == "true"

allow_from = env_list("WHATSAPP_ALLOW_FROM")
if allow_from is not None:
    whatsapp["allowFrom"] = allow_from

group_allow_from = env_list("WHATSAPP_GROUP_ALLOW_FROM")
if group_allow_from is not None:
    whatsapp["groupAllowFrom"] = group_allow_from

groups = env_list("WHATSAPP_GROUPS")
if groups is not None:
    whatsapp["groups"] = groups

with open(config_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY
}

generate_token() {
  python3 - <<'PY'
import secrets
print(secrets.token_hex(24))
PY
}

CONFIG_FILE_RAW="$(openclaw --profile "$PROFILE" config file 2>/dev/null || true)"
CONFIG_FILE=""
EXISTING_TOKEN=""
if [ -n "$CONFIG_FILE_RAW" ]; then
  CONFIG_FILE="$(expand_path "$CONFIG_FILE_RAW")"
  EXISTING_TOKEN="$(read_config_value "$CONFIG_FILE" "gateway.auth.token")"
fi
if [ "$EXISTING_TOKEN" = "__OPENCLAW_REDACTED__" ]; then
  EXISTING_TOKEN=""
fi
GATEWAY_TOKEN="${OPENCLAW_GATEWAY_TOKEN:-$EXISTING_TOKEN}"
if [ -z "$GATEWAY_TOKEN" ]; then
  GATEWAY_TOKEN="$(generate_token)"
fi

echo "Configuring native OpenClaw profile '$PROFILE'"
openclaw --profile "$PROFILE" onboard \
  --non-interactive \
  --accept-risk \
  --mode local \
  --workspace "$ROOT" \
  --auth-choice ollama \
  --gateway-port "$PORT" \
  --gateway-bind "$BIND" \
  --gateway-auth token \
  --gateway-token "$GATEWAY_TOKEN" \
  --skip-bootstrap \
  --skip-channels \
  --skip-daemon \
  --skip-health \
  --skip-search \
  --skip-skills \
  --skip-ui \
  --no-install-daemon \
  --json >/dev/null

openclaw --profile "$PROFILE" models set "$MODEL_REF"
openclaw --profile "$PROFILE" config set agents.defaults.skills '["conference-assistant"]' --strict-json >/dev/null
openclaw --profile "$PROFILE" config set agents.defaults.timeoutSeconds 300 --strict-json >/dev/null
if [ "${OPENCLAW_SKIP_WHATSAPP_PLUGIN_INSTALL:-0}" != "1" ]; then
  openclaw --profile "$PROFILE" plugins install @openclaw/whatsapp >/dev/null 2>&1 || true
fi
CONFIG_FILE_RAW="$(openclaw --profile "$PROFILE" config file)"
CONFIG_FILE="$(expand_path "$CONFIG_FILE_RAW")"
write_gateway_token "$CONFIG_FILE" "$GATEWAY_TOKEN"
patch_whatsapp_config "$CONFIG_FILE"
openclaw --profile "$PROFILE" config validate >/dev/null

echo "OpenClaw profile '$PROFILE' is configured with model '$MODEL_REF'"
echo "OpenClaw profile '$PROFILE' is restricted to the conference-assistant skill"
echo "WhatsApp channel enabled with DM policy '$WHATSAPP_DM_POLICY'"
