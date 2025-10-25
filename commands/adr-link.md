---
description: Create relationships between ADRs (supersedes, relates-to, extends, conflicts)
argument-hint: <from-ADR-ID> <relationship> <to-ADR-ID>
allowed-tools: Bash, Read, Edit
---

# Link ADRs

You are helping the user create relationships between Architecture Decision Records.

## Relationship Types

- **supersedes** - This ADR replaces another (automatically marks target as Superseded)
- **relates-to** - This ADR is related to another
- **extends** - This ADR extends/builds upon another
- **conflicts** - This ADR conflicts with another

## Process

1. **Parse arguments**:
   - $1 = From ADR-ID (e.g., ADR-005)
   - $2 = Relationship type
   - $3 = To ADR-ID (e.g., ADR-001)

2. **Create the link** using decision-link.sh:
   ```bash
   bash scripts/decision-link.sh $1 $2 $3
   ```

3. **Confirm the relationship** was created

## Examples

- `/adr-link ADR-005 supersedes ADR-001` - ADR-005 replaces ADR-001
- `/adr-link ADR-003 relates-to ADR-002` - ADR-003 relates to ADR-002
- `/adr-link ADR-007 extends ADR-004` - ADR-007 builds on ADR-004
- `/adr-link ADR-006 conflicts ADR-003` - ADR-006 conflicts with ADR-003

## Notes

- Links appear in the ADR content after the Date field
- "supersedes" relationships automatically update the target ADR's status to "Superseded"
- You can create multiple relationships for a single ADR
- Links are bidirectional in meaning but unidirectional in storage
