#!/bin/bash
# Updates the status of an existing ADR
# Usage: ./decision-status.sh <ADR-ID> <new-status> [superseded-by-ADR-ID]

set -e

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

ADR_ID="$1"
NEW_STATUS="$2"
SUPERSEDED_BY="$3"

DECISIONS_FILE="${PLUGIN_ROOT}/docs/DECISIONS.md"

if [ -z "$ADR_ID" ] || [ -z "$NEW_STATUS" ]; then
  echo "Usage: $0 <ADR-ID> <new-status> [superseded-by-ADR-ID]"
  echo ""
  echo "Valid statuses: Proposed, Accepted, Deprecated, Superseded"
  echo ""
  echo "Examples:"
  echo "  $0 ADR-001 Accepted"
  echo "  $0 ADR-001 Superseded ADR-005"
  exit 1
fi

# Validate status
case "$NEW_STATUS" in
  Proposed|Accepted|Deprecated|Superseded)
    ;;
  *)
    echo "Error: Invalid status '$NEW_STATUS'"
    echo "Valid statuses: Proposed, Accepted, Deprecated, Superseded"
    exit 1
    ;;
esac

# Check if DECISIONS.md exists
if [ ! -f "$DECISIONS_FILE" ]; then
  echo "Error: $DECISIONS_FILE not found"
  exit 1
fi

# Check if ADR exists
if ! grep -q "^## $ADR_ID:" "$DECISIONS_FILE"; then
  echo "Error: $ADR_ID not found in $DECISIONS_FILE"
  exit 1
fi

# Update status in ADR section
sed -i "/^## $ADR_ID:/,/^## ADR-/ {
  s/^\*\*Status:\*\* .*$/\*\*Status:\*\* $NEW_STATUS/
}" "$DECISIONS_FILE"

# If superseded, add reference
if [ "$NEW_STATUS" = "Superseded" ] && [ -n "$SUPERSEDED_BY" ]; then
  # Check if superseded-by ADR exists
  if ! grep -q "^## $SUPERSEDED_BY:" "$DECISIONS_FILE"; then
    echo "Warning: $SUPERSEDED_BY not found in $DECISIONS_FILE"
  else
    # Add superseded note after status
    sed -i "/^## $ADR_ID:/,/^## ADR-/ {
      /^\*\*Status:\*\* Superseded/ a\\
\\
**Superseded by:** [$SUPERSEDED_BY](#$(echo "$SUPERSEDED_BY" | tr '[:upper:]' '[:lower:]'))
    }" "$DECISIONS_FILE"
  fi
fi

# Update status in index
ADR_TITLE=$(grep "^## $ADR_ID:" "$DECISIONS_FILE" | sed "s/^## $ADR_ID: //")
SLUG=$(echo "$ADR_TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
ANCHOR="$(echo "$ADR_ID-$SLUG" | tr '[:upper:]' '[:lower:]')"

# Update or add status in index
if grep -q "- \[$ADR_ID: $ADR_TITLE\]" "$DECISIONS_FILE"; then
  sed -i "s|- \[$ADR_ID: $ADR_TITLE\](#$ANCHOR).*|- [$ADR_ID: $ADR_TITLE](#$ANCHOR) - $NEW_STATUS|" "$DECISIONS_FILE"
fi

echo "✓ Updated $ADR_ID status to: $NEW_STATUS"
if [ "$NEW_STATUS" = "Superseded" ] && [ -n "$SUPERSEDED_BY" ]; then
  echo "  Superseded by: $SUPERSEDED_BY"
fi

# Auto-sync to SPECIFICATION.md if spec-sync.sh exists
if [ -f "${SCRIPT_DIR}/spec-sync.sh" ]; then
  bash "${SCRIPT_DIR}/spec-sync.sh" 2>/dev/null || true
fi

exit 0
