#!/usr/bin/env bash
set -euo pipefail

VM_NAME="${CODEX_AGENT_VM_NAME:-codex-agent}"
WORKDIR_IN_VM="${CODEX_AGENT_WORKDIR:-/workspace}"

if [ "$#" -eq 0 ]; then
  limactl shell --workdir "$WORKDIR_IN_VM" "$VM_NAME" -- bash -lc "codex --sandbox workspace-write --ask-for-approval on-request"
else
  PROMPT="$*"
  limactl shell --workdir "$WORKDIR_IN_VM" "$VM_NAME" -- bash -lc "codex exec --sandbox workspace-write --ask-for-approval never \"\$1\"" _ "$PROMPT"
fi
