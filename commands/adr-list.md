---
description: List and filter Architecture Decision Records by status or keyword
argument-hint: [--status <status>] [--keyword <keyword>] [--summary]
allowed-tools: Bash, Read
---

# List ADRs

You are helping the user list and filter Architecture Decision Records.

## Usage Options

Execute the decision-list.sh script with optional filters:

**List all ADRs:**
```bash
bash scripts/decision-list.sh
```

**Filter by status:**
```bash
bash scripts/decision-list.sh --status Accepted
```

**Filter by keyword:**
```bash
bash scripts/decision-list.sh --keyword database
```

**Show summary statistics:**
```bash
bash scripts/decision-list.sh --summary
```

## Valid Status Values

- `Proposed` - Under consideration
- `Accepted` - Approved and implemented
- `Deprecated` - No longer recommended
- `Superseded` - Replaced by newer decision

## Interpretation

Parse the arguments from $ARGUMENTS and execute the appropriate command.

Examples:
- `/adr-list` → List all ADRs
- `/adr-list --status Accepted` → List only accepted ADRs
- `/adr-list --keyword security` → List ADRs mentioning security
- `/adr-list --summary` → Show statistics

After displaying results, offer to show details of specific ADRs or help create new ones.
