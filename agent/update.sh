#!/usr/bin/env bash
# Update an existing Managed Agent's system prompt.
#
# Managed Agents are versioned — the ID doesn't change across prompt edits,
# but each update increments the version and the API requires the current
# version for optimistic concurrency.
#
# Requires:
#   ANTHROPIC_API_KEY  Anthropic API key
#   AGENT_ID           existing agent ID (from `gh variable list --repo niemesrw/github-brain`)

set -euo pipefail

: "${ANTHROPIC_API_KEY:?ANTHROPIC_API_KEY is required}"
: "${AGENT_ID:?AGENT_ID is required}"

HEADERS=(
  -H "x-api-key: $ANTHROPIC_API_KEY"
  -H "anthropic-version: 2023-06-01"
  -H "anthropic-beta: managed-agents-2026-04-01"
  -H "content-type: application/json"
)

SYSTEM_PROMPT=$(cat "$(dirname "$0")/system-prompt.md")

echo "Fetching current version of $AGENT_ID..."
current=$(curl -sS --fail-with-body "https://api.anthropic.com/v1/agents/$AGENT_ID" "${HEADERS[@]}")
current_version=$(jq -er '.version' <<<"$current")
echo "Current version: $current_version"

echo "Updating..."
updated=$(curl -sS --fail-with-body "https://api.anthropic.com/v1/agents/$AGENT_ID" "${HEADERS[@]}" \
  -d "$(jq -n \
    --argjson version "$current_version" \
    --arg system "$SYSTEM_PROMPT" \
    '{version: $version, system: $system}')")

new_version=$(jq -er '.version' <<<"$updated")
echo "Updated. New version: $new_version"
