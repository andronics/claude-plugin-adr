---
description: Update the status of an existing ADR (Proposed, Accepted, Deprecated, Superseded)
argument-hint: <ADR-ID> <new-status> [superseded-by-ADR-ID]
allowed-tools: Bash, Read, Edit
---

# Update ADR Status

You are helping the user update the status of an Architecture Decision Record.

## Valid Status Transitions

- **Proposed** → **Accepted**: Decision has been implemented or approved
- **Accepted** → **Deprecated**: No longer recommended but still in use
- **Accepted** → **Superseded**: Replaced by a newer decision (requires new ADR ID)
- **Proposed** → **Deprecated**: Rejected before implementation

## Process

1. **Parse arguments**:
   - $1 = ADR-ID (e.g., ADR-001)
   - $2 = New status (Proposed, Accepted, Deprecated, Superseded)
   - $3 = Superseded-by ADR-ID (optional, required if status is Superseded)

2. **Update status** using decision-status.sh:
   ```bash
   bash scripts/decision-status.sh $1 $2 $3
   ```

3. **Confirm the update** and show the new status

## Examples

- `/adr-status ADR-001 Accepted`
- `/adr-status ADR-003 Superseded ADR-007`
- `/adr-status ADR-005 Deprecated`

## Notes

- If status is Superseded, the script will automatically update both ADRs
- Status changes are reflected in both the ADR content and the index
- SPECIFICATION.md is automatically updated via hooks
