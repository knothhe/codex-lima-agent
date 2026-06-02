#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VM_NAME="${CODEX_AGENT_VM_NAME:-codex-agent}"
LIMA_FILE="$ROOT_DIR/lima/codex-agent.yaml"
HOST_WORKSPACE_DIR="${CODEX_AGENT_HOST_WORKSPACE:-$HOME/Documents/Codex-$VM_NAME}"

if ! command -v limactl >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    echo "limactl not found; installing Lima with Homebrew..."
    brew install lima
  else
    echo "limactl not found."
    echo "Install Lima first: brew install lima"
    exit 1
  fi
fi

if limactl list --format '{{.Name}}' | grep -qx "$VM_NAME"; then
  echo "VM '$VM_NAME' already exists."
else
  mkdir -p "$HOST_WORKSPACE_DIR"
  TMP_LIMA_FILE="$(mktemp "${TMPDIR:-/tmp}/codex-agent.XXXXXX.yaml")"
  trap 'rm -f "$TMP_LIMA_FILE"' EXIT
  HOST_WORKSPACE_ESCAPED="${HOST_WORKSPACE_DIR//&/\\&}"
  sed "s#__CODEX_AGENT_HOST_WORKSPACE__#$HOST_WORKSPACE_ESCAPED#g" "$LIMA_FILE" > "$TMP_LIMA_FILE"
  limactl start --name="$VM_NAME" "$TMP_LIMA_FILE"
fi

echo
echo "Host workspace:"
echo "  $HOST_WORKSPACE_DIR"
echo
echo "Enter VM:"
echo "  $ROOT_DIR/bin/enter.sh"
echo
echo "First login inside VM:"
echo "  codex login --device-auth"
