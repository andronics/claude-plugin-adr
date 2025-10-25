#!/bin/bash
# Creates relationships between ADRs (supersedes, relates to)
# Usage: ./decision-link.sh <from-ADR-ID> <relationship> <to-ADR-ID>

set -e

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

FROM_ADR="$1"
RELATIONSHIP="$2"
TO_ADR="$3"

DECISIONS_FILE="${PLUGIN_ROOT}/docs/DECISIONS.md"

if [ -z "$FROM_ADR" ] || [ -z "$RELATIONSHIP" ] || [ -z "$TO_ADR" ]; then
  echo "Usage: $0 <from-ADR-ID> <relationship> <to-ADR-ID>"
  echo ""
  echo "Relationships:"
  echo "  supersedes    - This ADR supersedes another (marks target as Superseded)"
  echo "  relates-to    - This ADR relates to another"
  echo "  extends       - This ADR extends another"
  echo "  conflicts     - This ADR conflicts with another"
  echo ""
  echo "Examples:"
  echo "  $0 ADR-005 supersedes ADR-001"
  echo "  $0 ADR-003 relates-to ADR-002"
  exit 1
fi

# Validate relationship
case "$RELATIONSHIP" in
  supersedes|relates-to|extends|conflicts)
    ;;
  *)
    echo "Error: Invalid relationship '$RELATIONSHIP'"
    echo "Valid relationships: supersedes, relates-to, extends, conflicts"
    exit 1
    ;;
esac

# Check if DECISIONS.md exists
if [ ! -f "$DECISIONS_FILE" ]; then
  echo "Error: $DECISIONS_FILE not found"
  exit 1
fi

# Check if both ADRs exist
if ! grep -q "^## $FROM_ADR:" "$DECISIONS_FILE"; then
  echo "Error: $FROM_ADR not found in $DECISIONS_FILE"
  exit 1
fi

if ! grep -q "^## $TO_ADR:" "$DECISIONS_FILE"; then
  echo "Error: $TO_ADR not found in $DECISIONS_FILE"
  exit 1
fi

# Generate anchor for TO_ADR
TO_ADR_TITLE=$(grep "^## $TO_ADR:" "$DECISIONS_FILE" | sed "s/^## $TO_ADR: //")
TO_SLUG=$(echo "$TO_ADR_TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
TO_ANCHOR="$(echo "$TO_ADR-$TO_SLUG" | tr '[:upper:]' '[:lower:]')"

# Create relationship text
case "$RELATIONSHIP" in
  supersedes)
    LINK_TEXT="**Supersedes:** [$TO_ADR: $TO_ADR_TITLE](#$TO_ANCHOR)"
    # Also update the superseded ADR
    bash "${SCRIPT_DIR}/decision-status.sh" "$TO_ADR" "Superseded" "$FROM_ADR" 2>/dev/null || true
    ;;
  relates-to)
    LINK_TEXT="**Related to:** [$TO_ADR: $TO_ADR_TITLE](#$TO_ANCHOR)"
    ;;
  extends)
    LINK_TEXT="**Extends:** [$TO_ADR: $TO_ADR_TITLE](#$TO_ANCHOR)"
    ;;
  conflicts)
    LINK_TEXT="**Conflicts with:** [$TO_ADR: $TO_ADR_TITLE](#$TO_ANCHOR)"
    ;;
esac

# Check if relationship already exists
if sed -n "/^## $FROM_ADR:/,/^## ADR-/p" "$DECISIONS_FILE" | grep -q "$LINK_TEXT"; then
  echo "Relationship already exists between $FROM_ADR and $TO_ADR"
  exit 0
fi

# Add relationship after the Date field in FROM_ADR
# Find the line with Date and add after it
TEMP_FILE=$(mktemp)
awk -v from="$FROM_ADR" -v link="$LINK_TEXT" '
  /^## ADR-/ { in_section = ($0 ~ "^## " from ":") }
  in_section && /^\*\*Date:\*\*/ {
    print
    if (!added) {
      print ""
      print link
      added = 1
    }
    next
  }
  /^## ADR-/ && !/^## '"$FROM_ADR"':/ { in_section = 0; added = 0 }
  { print }
' "$DECISIONS_FILE" > "$TEMP_FILE"

mv "$TEMP_FILE" "$DECISIONS_FILE"

echo "✓ Created relationship: $FROM_ADR $RELATIONSHIP $TO_ADR"

if [ "$RELATIONSHIP" = "supersedes" ]; then
  echo "  Also marked $TO_ADR as Superseded"
fi

# Auto-sync to SPECIFICATION.md if spec-sync.sh exists
if [ -f "${SCRIPT_DIR}/spec-sync.sh" ]; then
  bash "${SCRIPT_DIR}/spec-sync.sh" 2>/dev/null || true
fi

exit 0
