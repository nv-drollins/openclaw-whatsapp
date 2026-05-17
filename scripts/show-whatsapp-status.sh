#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=openclaw-env.sh
. "$SCRIPT_DIR/openclaw-env.sh"
# shellcheck source=load-whatsapp-env.sh
. "$SCRIPT_DIR/load-whatsapp-env.sh"

PROFILE="${OPENCLAW_PROFILE:-openclaw-whatsapp}"

openclaw_require_cli

openclaw --profile "$PROFILE" channels status
