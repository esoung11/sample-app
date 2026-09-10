#!/usr/bin/env bash
set -euo pipefail
output="$(./hello.sh)"
if [[ "$output" == "Hello from the homelab pipeline" ]]; then
  echo "PASS"
else
  echo "FAIL: unexpected output: $output"
  exit 1
fi
