---
description: Create a new Architecture Decision Record (ADR) with context, options, and consequences
argument-hint: <decision-title>
allowed-tools: Bash, Read, Write, Edit
---

# Create New ADR

You are helping the user create a new Architecture Decision Record (ADR) following Michael Nygard's template.

## Process

1. **Get the decision title** from $ARGUMENTS (or ask if not provided)
2. **Create the ADR** using the decision-record.sh script:
   ```bash
   bash scripts/decision-record.sh $ARGUMENTS
   ```
3. **Guide the user** to fill in the template sections:
   - Context: What situation/problem necessitates this decision?
   - Decision: What was decided?
   - Options Considered: What alternatives were evaluated? (mark chosen option)
   - Consequences: What are the positive and negative outcomes?
   - Implementation Notes: Any specific details or follow-up actions?

4. **Offer to edit** the newly created ADR in docs/DECISIONS.md

## Example Workflow

User: `/adr-create Use PostgreSQL for primary database`