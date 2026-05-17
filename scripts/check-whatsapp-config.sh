#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=load-whatsapp-env.sh
. "$SCRIPT_DIR/load-whatsapp-env.sh"

QUIET=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --quiet) QUIET=1 ;;
    -h|--help)
      echo "Usage: $0 [--quiet]"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

DM_POLICY="${WHATSAPP_DM_POLICY:-pairing}"
GROUP_POLICY="${WHATSAPP_GROUP_POLICY:-disabled}"
ACCOUNT="${WHATSAPP_ACCOUNT:-default}"

case "$DM_POLICY" in
  pairing|allowlist|open|disabled) ;;
  *) echo "WHATSAPP_DM_POLICY must be pairing, allowlist, open, or disabled." >&2; exit 1 ;;
esac

case "$GROUP_POLICY" in
  allowlist|open|disabled) ;;
  *) echo "WHATSAPP_GROUP_POLICY must be allowlist, open, or disabled." >&2; exit 1 ;;
esac

if [ "$DM_POLICY" = "open" ] && [ "${WHATSAPP_ALLOW_FROM:-}" != "*" ]; then
  echo "WHATSAPP_DM_POLICY=open requires WHATSAPP_ALLOW_FROM=*." >&2
  exit 1
fi

if [ "$GROUP_POLICY" = "open" ] && [ "${WHATSAPP_GROUP_ALLOW_FROM:-}" != "*" ]; then
  echo "WHATSAPP_GROUP_POLICY=open requires WHATSAPP_GROUP_ALLOW_FROM=*." >&2
  exit 1
fi

if [ "$QUIET" -eq 0 ]; then
  echo "WhatsApp account: $ACCOUNT"
  echo "WhatsApp DM policy: $DM_POLICY"
  echo "WhatsApp group policy: $GROUP_POLICY"
  if [ -n "${WHATSAPP_ALLOW_FROM:-}" ]; then
    echo "WhatsApp DM allowlist: $WHATSAPP_ALLOW_FROM"
  fi
  if [ -n "${WHATSAPP_GROUP_ALLOW_FROM:-}" ]; then
    echo "WhatsApp group sender allowlist: $WHATSAPP_GROUP_ALLOW_FROM"
  fi
fi
