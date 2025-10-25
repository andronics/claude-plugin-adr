---
name: decision-recorder
description: Records architectural decisions in ADR (Architecture Decision Record) format with context, options, and consequences. Use when making plugin architecture decisions that need documentation. Automatically syncs to SPECIFICATION.md.
allowed-tools: Read, Write, Edit, Bash
---

# Decision Recorder Skill

This skill records architectural decisions using the ADR (Architecture Decision Record) format in `docs/DECISIONS.md`.

All ADRs are automatically synced to SPECIFICATION.md via the spec-sync.sh script.

## What This Skill Does

1. **ADR Creation**: Generates new architecture decision records
2. **Sequential Numbering**: Auto-increments ADR numbers (ADR-001, ADR-002, etc.)
3. **Structured Format**: Follows Michael Nygard's ADR template
4. **Status Tracking**: Manages decision lifecycle (Proposed/Accepted/Deprecated/Superseded)
5. **Index Management**: Maintains searchable index of all decisions
6. **Context Preservation**: Documents why decisions were made

## ADR Format

```markdown
## ADR-XXX: Decision Title

**Status:** Proposed|Accepted|Deprecated|Superseded

**Date:** YYYY-MM-DD

**Context:**
[Problem statement and forces at play]

**Decision:**
[The decision made]

**Options Considered:**

1. **Option 1**
   - Pros: [Benefits]
   - Cons: [Drawbacks]

2. **Option 2 (CHOSEN)**
   - Pros: [Benefits]
   - Cons: [Drawbacks]

**Consequences:**

**Positive:**
- [Positive outcomes]

**Negative:**
- [Trade-offs and negative outcomes]

**Implementation Notes:**
[Details, gotchas, follow-up actions]
```

## Status Definitions

- **Proposed**: Under consideration, not yet implemented
- **Accepted**: Decision made and being/has been implemented
- **Deprecated**: No longer recommended, but existing implementations remain
- **Superseded**: Replaced by newer decision (references new ADR)

## Usage

When invoked, this skill will:

1. Read existing `docs/DECISIONS.md` (create if missing)
2. Determine next ADR number
3. Generate ADR entry from provided information
4. Add to index with clickable link
5. Append full ADR to document
6. Output confirmation with ADR ID

## When to Create ADRs

Record decisions for:
- Plugin architecture choices
- Technology/framework selections
- Design pattern adoptions
- Breaking changes
- Significant refactoring approaches
- Security model choices
- API design decisions

## Decision Review Process

1. **Create**: Initially mark as "Proposed"
2. **Review**: Discuss with team/stakeholders
3. **Accept**: Change status to "Accepted" when implemented
4. **Deprecate**: Mark "Deprecated" if no longer recommended
5. **Supersede**: Mark "Superseded" with reference to new ADR

## Implementation

Uses the following scripts:
- `scripts/decision-record.sh` - Create new ADRs
- `scripts/decision-status.sh` - Update ADR status (Proposed → Accepted, etc.)
- `scripts/decision-list.sh` - List and filter ADRs
- `scripts/decision-link.sh` - Create relationships between ADRs
- `scripts/spec-sync.sh` - Auto-sync ADRs to SPECIFICATION.md

## Slash Commands

Users can also interact with ADRs via slash commands:
- `/adr-create <title>` - Create new ADR interactively
- `/adr-status <ADR-ID> <status>` - Update ADR status
- `/adr-list [options]` - List/filter ADRs
- `/adr-link <from> <rel> <to>` - Link ADRs together

## Benefits

- **Traceable**: Know why decisions were made
- **Onboarding**: New developers understand rationale
- **Reversible**: Document when/why decisions change
- **Collaborative**: Team discusses options before deciding
- **Historical**: Preserve institutional knowledge
