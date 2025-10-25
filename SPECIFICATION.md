# Claude Plugin Architecture Decision Records - Complete Specification

## Overview

A comprehensive Architecture Decision Records (ADR) plugin for Claude Code following Michael Nygard's template with:

- Sequential numbering (ADR-001, ADR-002, etc.)
- Status tracking (Proposed, Accepted, Deprecated, Superseded)
- Context, decision, options considered, consequences
- Searchable index in docs/DECISIONS.md
- Integration with decision-recorder skill
- Automatic sync to SPECIFICATION.md
- Relationship tracking between decisions

## Plugin Architecture

### Core Components

1. **Plugin Manifest** (`.claude-plugin/plugin.json`)
   - Name: `adr`
   - Version: 1.0.0
   - Metadata: author, keywords, repository

2. **Slash Commands** (`commands/`)
   - `/adr-create <title>` - Create new ADR interactively
   - `/adr-status <ADR-ID> <status> [superseded-by]` - Update ADR status
   - `/adr-list [--status|--keyword|--summary]` - List/filter ADRs
   - `/adr-link <from> <rel> <to>` - Create ADR relationships

3. **Skills** (`skills/decision-recorder/`)
   - Model-invoked skill for automatic ADR creation
   - Triggers on architecture discussion keywords
   - Uses Read, Write, Edit, Bash tools

4. **Scripts** (`scripts/`)
   - `decision-record.sh` - Create new ADR with template
   - `decision-status.sh` - Update ADR status with validation
   - `decision-list.sh` - List/filter ADRs by status or keyword
   - `decision-link.sh` - Create relationships (supersedes, relates-to, extends, conflicts)

5. **Documentation** (`docs/`)
   - `DECISIONS.md` - Master ADR document with index
   - `README.md` - Plugin documentation and usage guide

## Living Specification

This specification serves as both documentation and recovery mechanism. The entire plugin can be regenerated from this document alone.

### Recovery Capability

This specification enables complete plugin regeneration with:
- All slash commands and their frontmatter
- Skill configuration and allowed tools
- Shell scripts with full logic
- Hooks system configuration
- Documentation structure
- Directory organization
- File naming conventions

## File Structure

```
claude-plugin-adr/
├── .claude-plugin/
│   └── plugin.json                    # Plugin manifest
├── commands/
│   ├── adr-create.md                  # Create new ADR
│   ├── adr-status.md                  # Update ADR status
│   ├── adr-list.md                    # List/filter ADRs
│   └── adr-link.md                    # Link ADRs
├── scripts/
│   ├── decision-record.sh             # Create ADR
│   ├── decision-status.sh             # Update status
│   ├── decision-list.sh               # List ADRs
│   └── decision-link.sh               # Link ADRs
├── skills/
│   └── decision-recorder/
│       └── SKILL.md                   # Model-invoked skill
├── docs/
│   ├── DECISIONS.md                   # All ADRs
│   └── README.md                      # Documentation
└── SPECIFICATION.md                   # This file
```

## ADR Format Specification

### Template Structure

```markdown
## ADR-XXX: Decision Title

**Status:** Proposed|Accepted|Deprecated|Superseded

**Date:** YYYY-MM-DD

[Optional Relationships]
**Supersedes:** [ADR-YYY](#link)
**Related to:** [ADR-ZZZ](#link)

**Context:**
[Problem statement, forces at play, constraints]

**Decision:**
[Clear statement of what was decided]

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
- [Trade-offs, negative outcomes]

**Implementation Notes:**
[Details, gotchas, follow-up actions]
```

### Status Lifecycle

```
Proposed → Accepted → Deprecated
                   → Superseded (by new ADR)
```

### Relationship Types

- **supersedes**: Replaces another ADR (auto-marks target as Superseded)
- **relates-to**: Related to another ADR
- **extends**: Builds upon another ADR
- **conflicts**: Conflicts with another ADR

## Script Specifications

### decision-record.sh

**Purpose**: Create new ADR with sequential numbering

**Logic**:
1. Parse title from arguments
2. Determine next ADR number (read existing, increment)
3. Generate slug and anchor from title
4. Add entry to index section
5. Append full ADR template
6. Trigger spec-sync.sh if available

**Key Features**:
- Uses `${PLUGIN_ROOT}` for portability
- Creates docs/ directory if needed
- Initializes DECISIONS.md if missing
- Zero-padded 3-digit numbering (001, 002)

### decision-status.sh

**Purpose**: Update ADR status with validation

**Logic**:
1. Validate status (Proposed|Accepted|Deprecated|Superseded)
2. Check ADR exists
3. Update status in ADR body
4. Add superseded-by reference if applicable
5. Update index entry
6. Trigger spec-sync.sh

### decision-list.sh

**Purpose**: List and filter ADRs

**Options**:
- `--status <status>`: Filter by status
- `--keyword <keyword>`: Search in title/content
- `--summary`: Show statistics

**Output Format**:
```
ADR-XXX      [Status]     Decision Title
             Date: YYYY-MM-DD
```

### decision-link.sh

**Purpose**: Create relationships between ADRs

**Relationships**:
- supersedes: Marks target as Superseded
- relates-to: Creates reference
- extends: Indicates extension
- conflicts: Notes conflict

**Logic**:
1. Validate both ADRs exist
2. Generate anchor link
3. Insert relationship after Date field
4. If supersedes, update target status

### spec-sync.sh

**Purpose**: Sync ADR index to SPECIFICATION.md

**Logic**:
1. Extract index from DECISIONS.md
2. Take top 10 recent ADRs
3. Replace or append to "Recent Architecture Decisions" section
4. Maintain SPECIFICATION.md structure

## Slash Command Specifications

### adr-create.md

**Frontmatter**:
```yaml
description: Create new ADR with context, options, consequences
argument-hint: <decision-title>
allowed-tools: Bash, Read, Write, Edit
```

**Behavior**:
- Execute decision-record.sh with title
- Guide user through filling template
- Offer to edit DECISIONS.md

### adr-status.md

**Frontmatter**:
```yaml
description: Update ADR status (Proposed → Accepted, etc.)
argument-hint: <ADR-ID> <new-status> [superseded-by-ADR-ID]
allowed-tools: Bash, Read, Edit
```

**Behavior**:
- Parse ADR-ID and status
- Execute decision-status.sh
- Confirm update

### adr-list.md

**Frontmatter**:
```yaml
description: List/filter ADRs by status or keyword
argument-hint: [--status <status>] [--keyword <keyword>] [--summary]
allowed-tools: Bash, Read
```

**Behavior**:
- Parse filter options
- Execute decision-list.sh
- Display results

### adr-link.md

**Frontmatter**:
```yaml
description: Create relationships between ADRs
argument-hint: <from-ADR-ID> <relationship> <to-ADR-ID>
allowed-tools: Bash, Read, Edit
```

**Behavior**:
- Parse from, relationship, to
- Execute decision-link.sh
- Confirm link creation

## Skill Specification

### decision-recorder

**Frontmatter**:
```yaml
name: decision-recorder
description: Records architectural decisions in ADR format with context, options, consequences. Use when making plugin architecture decisions. Automatically syncs to SPECIFICATION.md.
allowed-tools: Read, Write, Edit, Bash
```

**Trigger Keywords**:
- "architecture decision"
- "technical decision"
- "design choice"
- "we decided to"
- "should we use"
- "framework selection"

**Behavior**:
1. Identify decision being discussed
2. Execute decision-record.sh
3. Guide user through template
4. Auto-sync to SPECIFICATION.md


## Usage Patterns

### Creating First ADR

```bash
/adr-create Use Michael Nygard ADR template
# Edit DECISIONS.md to fill in:
# - Context: Need standard format for decisions
# - Options: Nygard vs MADR vs Y-statements
# - Decision: Chose Nygard for simplicity
# - Consequences: Well-known format, easy to understand
```

### Updating Status

```bash
/adr-status ADR-001 Accepted
```

### Superseding Decision

```bash
/adr-create Use GraphQL instead of REST
/adr-link ADR-005 supersedes ADR-002
# ADR-002 automatically marked as Superseded
```

### Viewing All Accepted Decisions

```bash
/adr-list --status Accepted
```

### Checking Statistics

```bash
/adr-list --summary
# Output:
# Total: 12
# Proposed: 3
# Accepted: 7
# Deprecated: 1
# Superseded: 1
```

## Integration Points

### With SPECIFICATION.md

- Recent ADRs section auto-updated
- Enables plugin recovery
- Maintains sync via hooks

### With Skills

- decision-recorder skill auto-invokes
- Uses scripts for consistency
- Allows manual override

### With Slash Commands

- User-explicit control
- Direct script execution
- Interactive guidance

## Best Practices

### When to Create ADRs

- Significant architectural choices
- Technology selections
- Design pattern adoptions
- Breaking changes
- Security decisions
- Performance trade-offs

### Status Transitions

- Start with **Proposed** for discussion
- Move to **Accepted** when implemented
- Use **Deprecated** when discouraged but still present
- Use **Superseded** when replaced by new ADR

### Writing Quality ADRs

- **Context**: Explain the forces, not just the problem
- **Options**: List real alternatives considered, not straw men
- **Consequences**: Include both positive and negative outcomes
- **Concise**: Keep focused on the decision, not implementation details

## Extension Points

### Additional Scripts

Create new scripts for:
- ADR exports (PDF, HTML)
- Integration with issue trackers
- Automated decision proposals

## Reference Documentation

Implementation based on official Claude Code documentation:

- [Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)
- [Sub-Agents](https://docs.claude.com/en/docs/claude-code/sub-agents)
- [Skills](https://docs.claude.com/en/docs/claude-code/skills)
- [Slash Commands](https://docs.claude.com/en/docs/claude-code/slash-commands)
- [Hooks](https://docs.claude.com/en/docs/claude-code/hooks)
- [Plugin Marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
- [Output Styles](https://docs.claude.com/en/docs/claude-code/output-styles)

## Version History

### 1.0.0 (Current)

**Initial Release**:
- Complete ADR system with Nygard template
- 4 slash commands for user control
- 4 scripts for ADR lifecycle
- 1 skill for model invocation
- Auto-sync hooks to SPECIFICATION.md
- Relationship tracking between ADRs
- Comprehensive documentation

**Future Enhancements**:
- Export to multiple formats (PDF, HTML)
- Integration with external tools
- Templates for different decision types
- Visualization of decision graphs
- Search and analytics capabilities
