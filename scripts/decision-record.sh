#!/bin/bash
# Creates new architecture decision record
# Usage: ./decision-record.sh <decision-title>

set -e

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

TITLE="$*"
DECISIONS_FILE="${PLUGIN_ROOT}/docs/DECISIONS.md"

if [ -z "$TITLE" ]; then
  echo "Usage: $0 <decision-title>"
  exit 1
fi

# Create docs directory if needed
mkdir -p "${PLUGIN_ROOT}/docs"

# Initialize DECISIONS.md if it doesn't exist
if [ ! -f "$DECISIONS_FILE" ]; then
  cat > "$DECISIONS_FILE" <<'EOF'
# Architecture Decision Records

This document tracks all significant architectural decisions for this plugin.

Format based on [Michael Nygard's ADR template](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions).

## Index

---
EOF
fi

# Generate ADR number
LAST_NUM=$(grep -oP 'ADR-\K\d+' "$DECISIONS_FILE" 2>/dev/null | sort -n | tail -1 || echo "0")
ADR_NUM=$(printf "%03d" $((LAST_NUM + 1)))
ADR_ID="ADR-$ADR_NUM"

# Generate slug from title
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
ANCHOR="$(echo "$ADR_ID-$SLUG" | tr '[:upper:]' '[:lower:]')"

DATE=$(date +%Y-%m-%d)

# Add to index
sed -i "/^## Index/a - [$ADR_ID: $TITLE](#$ANCHOR) - Proposed" "$DECISIONS_FILE"

# Create ADR entry
cat >> "$DECISIONS_FILE" <<EOF

## $ADR_ID: $TITLE

**Status:** Proposed

**Date:** $DATE

**Context:**
[Describe the situation, problem, and forces at play]

**Decision:**
[State the decision clearly and concisely]

**Options Considered:**

1. **Option 1**
   - Pros: [Benefits]
   - Cons: [Drawbacks]

2. **Option 2 (CHOSEN)**
   - Pros: [Benefits]
   - Cons: [Drawbacks]

**Consequences:**

**Positive:**
- [List positive outcomes]

**Negative:**
- [List negative outcomes or trade-offs]

**Implementation Notes:**
[Any implementation details, gotchas, or follow-up actions]
EOF

echo "✓ Created $ADR_ID: $TITLE"
echo "  File: $DECISIONS_FILE"
echo "  Status: Proposed"

# Auto-sync to SPECIFICATION.md if spec-sync.sh exists
if [ -f "${SCRIPT_DIR}/spec-sync.sh" ]; then
  bash "${SCRIPT_DIR}/spec-sync.sh" 2>/dev/null || true
fi

exit 0
