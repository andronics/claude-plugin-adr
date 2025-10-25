#!/bin/bash
# Lists and filters Architecture Decision Records
# Usage: ./decision-list.sh [options]

set -e

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

DECISIONS_FILE="${PLUGIN_ROOT}/docs/DECISIONS.md"

# Default filter options
FILTER_STATUS=""
FILTER_KEYWORD=""
SHOW_SUMMARY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --status|-s)
      FILTER_STATUS="$2"
      shift 2
      ;;
    --keyword|-k)
      FILTER_KEYWORD="$2"
      shift 2
      ;;
    --summary)
      SHOW_SUMMARY=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  -s, --status <status>    Filter by status (Proposed, Accepted, Deprecated, Superseded)"
      echo "  -k, --keyword <keyword>  Filter by keyword in title or content"
      echo "  --summary                Show summary statistics"
      echo "  -h, --help               Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0                       # List all ADRs"
      echo "  $0 --status Accepted     # List only accepted ADRs"
      echo "  $0 --keyword database    # List ADRs containing 'database'"
      echo "  $0 --summary             # Show statistics"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Check if DECISIONS.md exists
if [ ! -f "$DECISIONS_FILE" ]; then
  echo "No ADRs found. Create one with: decision-record.sh <title>"
  exit 0
fi

# Show summary if requested
if [ "$SHOW_SUMMARY" = true ]; then
  TOTAL=$(grep -c "^## ADR-" "$DECISIONS_FILE" || echo "0")
  PROPOSED=$(grep -A1 "^## ADR-" "$DECISIONS_FILE" | grep -c "Status:\*\* Proposed" || echo "0")
  ACCEPTED=$(grep -A1 "^## ADR-" "$DECISIONS_FILE" | grep -c "Status:\*\* Accepted" || echo "0")
  DEPRECATED=$(grep -A1 "^## ADR-" "$DECISIONS_FILE" | grep -c "Status:\*\* Deprecated" || echo "0")
  SUPERSEDED=$(grep -A1 "^## ADR-" "$DECISIONS_FILE" | grep -c "Status:\*\* Superseded" || echo "0")

  echo "ADR Summary"
  echo "==========="
  echo "Total:      $TOTAL"
  echo "Proposed:   $PROPOSED"
  echo "Accepted:   $ACCEPTED"
  echo "Deprecated: $DEPRECATED"
  echo "Superseded: $SUPERSEDED"
  echo ""
  exit 0
fi

# Extract ADRs with their status
echo "Architecture Decision Records"
echo "============================="
echo ""

# Process each ADR
grep -n "^## ADR-" "$DECISIONS_FILE" | while IFS=: read -r line_num adr_line; do
  ADR_ID=$(echo "$adr_line" | grep -oP 'ADR-\d+')
  ADR_TITLE=$(echo "$adr_line" | sed "s/^## $ADR_ID: //")

  # Get status from next few lines
  STATUS=$(sed -n "$((line_num+1)),$((line_num+5))p" "$DECISIONS_FILE" | grep "^\*\*Status:\*\*" | sed 's/\*\*Status:\*\* //')

  # Get date
  DATE=$(sed -n "$((line_num+1)),$((line_num+10))p" "$DECISIONS_FILE" | grep "^\*\*Date:\*\*" | sed 's/\*\*Date:\*\* //')

  # Apply filters
  if [ -n "$FILTER_STATUS" ] && [ "$STATUS" != "$FILTER_STATUS" ]; then
    continue
  fi

  if [ -n "$FILTER_KEYWORD" ]; then
    # Get full ADR content for keyword search
    ADR_CONTENT=$(sed -n "/^## $ADR_ID:/,/^## ADR-/p" "$DECISIONS_FILE")
    if ! echo "$ADR_CONTENT" | grep -qi "$FILTER_KEYWORD"; then
      continue
    fi
  fi

  # Display ADR
  printf "%-12s %-12s %s\n" "$ADR_ID" "[$STATUS]" "$ADR_TITLE"
  if [ -n "$DATE" ]; then
    printf "             Date: %s\n" "$DATE"
  fi
  echo ""
done

exit 0
