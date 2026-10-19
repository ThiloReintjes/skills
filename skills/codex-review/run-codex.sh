#!/usr/bin/env bash
# Run one read-only Codex review on gpt-6.1-sol (reasoning high) through the
# local CLIProxyAPI. The ChatGPT login rejects this model, so requests must go
# through the proxy.
#
# Usage: run-codex.sh <repo-dir> <prompt-file> <output-file>
# Writes the review to <output-file> and the full Codex log to <output-file>.log.
set -euo pipefail

usage="usage: run-codex.sh <repo-dir> <prompt-file> <output-file>"
repo=${1:?$usage}
prompt_file=${2:?$usage}
output=${3:?$usage}
config=/opt/homebrew/etc/cliproxyapi.conf
base_url=http://127.0.0.1:8317/v1

# Codex refuses to run outside a trusted directory or git repository.
if ! git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
  echo "$repo is not a git repository; run the review from the repository being reviewed." >&2
  exit 1
fi

# First entry of the proxy's api-keys list, read without printing it.
CLIPROXY_API_KEY=$(awk '/^api-keys:/ { found = 1; next }
  found && /^ *- / { gsub(/^ *- *["'\'']?|["'\'']? *$/, ""); print; exit }' "$config")
if [[ -z "$CLIPROXY_API_KEY" ]]; then
  echo "No api-keys entry found in $config." >&2
  exit 1
fi
export CLIPROXY_API_KEY

status=$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $CLIPROXY_API_KEY" \
  "$base_url/models" || true)
if [[ "$status" != 200 ]]; then
  echo "CLIProxyAPI at $base_url answered '$status'. Start it with: brew services start cliproxyapi" >&2
  exit 1
fi

if ! codex exec -s read-only -C "$repo" -o "$output" \
  -c model="gpt-6.1-sol" \
  -c model_reasoning_effort="high" \
  -c model_provider="cliproxy" \
  -c model_providers.cliproxy.name="cliproxy" \
  -c model_providers.cliproxy.base_url="$base_url" \
  -c model_providers.cliproxy.env_key="CLIPROXY_API_KEY" \
  -c model_providers.cliproxy.wire_api="responses" \
  - <"$prompt_file" >"$output.log" 2>&1; then
  echo "Codex failed; see $output.log" >&2
  exit 1
fi
cat "$output"
