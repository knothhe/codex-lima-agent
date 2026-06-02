#!/usr/bin/env bash
set -euo pipefail

VM_NAME="${CODEX_AGENT_VM_NAME:-codex-agent}"
WORKDIR_IN_VM="${CODEX_AGENT_WORKDIR:-/workspace}"

limactl shell --workdir "$WORKDIR_IN_VM" "$VM_NAME"
