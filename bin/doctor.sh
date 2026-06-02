#!/usr/bin/env bash
set -euo pipefail

VM_NAME="${CODEX_AGENT_VM_NAME:-codex-agent}"

limactl shell "$VM_NAME" -- bash -lc '
set -e
echo "== system =="
uname -a
echo
echo "== tools =="
command -v codex
codex --version
node --version
npm --version
git --version
bwrap --version
echo
echo "== codex doctor =="
codex doctor --summary --ascii
'
