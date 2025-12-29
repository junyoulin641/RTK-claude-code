---
allowed-tools: Bash, Read, Write, LS, Task
---

# PRD New

Create a new Product Requirements Document for an existing project to add additional features.

## Usage
```
/pm:prd-new <project_name>
```

## Required Rules

**IMPORTANT:** Before executing this command, read and follow:
- `.claude/rules/datetime.md` - For getting real current date/time

## Preflight Checklist

Before proceeding, complete these validation steps.
Do not bother the user with preflight checks progress ("I'm not going to ..."). Just do them and move on.

### 1. Project Validation
- Run: `ls -la ./doc/$ARGUMENTS/ 2>/dev/null`
- Check if `./doc/$ARGUMENTS/PROJECT-PRD.md` exists
- Check if `./doc/$ARGUMENTS/prds/` directory exists
- If any missing: "❌ Project '$ARGUMENTS' not found. Please create it first with: /pm:project-new $ARGUMENTS"
- Stop execution if project doesn't exist

### 2. Get Feature Name
- Prompt user: "Enter new feature name for project '$ARGUMENTS' (e.g., advanced-ui, data-export):"
- Read feature name input
- Validate format: kebab-case (lowercase letters, numbers, hyphens)
- If invalid: "❌ Feature name must be kebab-case (lowercase, hyphens only)"

### 3. Check for Existing PRD
- Check if `./doc/$ARGUMENTS/prds/<feature_name>.md` already exists
- If exists: "⚠️ PRD '<feature_name>' already exists in this project"
- Ask user: "Do you want to overwrite it? (yes/no)"
- If no: Exit gracefully with "Operation cancelled. Use a different feature name or edit existing PRD with: /pm:prd-edit $ARGUMENTS <feature_name>"
- If yes: Continue

### 4. Read Project Context
- Run: `cat ./doc/$ARGUMENTS/PROJECT-PRD.md`
- Extract project overview and technical context
- Store for use in PRD brainstorming

## Instructions

You are creating a new Product Requirements Document for the existing project: **$ARGUMENTS**

### 1. Load Project Context

Read the existing `./doc/$ARGUMENTS/PROJECT-PRD.md` to understand:
- Project purpose and goals
- Technology stack used
- Architecture decisions
- Existing features and their status
- Project vision and direction

This context is CRITICAL to ensure the new feature aligns with the existing project.

### 2. Interactive Feature Brainstorming

Conduct a comprehensive brainstorming session for the new feature with user interaction.

You are creating a PRD for an existing project: **$ARGUMENTS**

Load and understand the existing `./doc/$ARGUMENTS/PROJECT-PRD.md`:
- Project purpose and goals
- Technology stack used (e.g., PyQt6, Python)
- Architecture and existing features
- Project vision and direction

**Guide the discussion through these areas:**

#### Discovery & Context
- Ask clarifying questions about what the new feature should do
- Understand the problem being solved
- Identify target users and use cases
- Gather constraints and requirements

#### PRD Structure Development
Ask questions that help define:

1. **Feature Overview**
   - "What is the main purpose of this new feature?"
   - "How does it extend the existing project?"
   - "What problems does it solve?"

2. **User Stories & Use Cases**
   - "Who will use this feature?"
   - "What actions will they take?"
   - "What value does it provide?"

3. **Technical Requirements**
   - "How will this integrate with existing components?"
   - "Any new dependencies needed?"
   - "Database or file storage needs?"

4. **Success Criteria**
   - "How will we know this feature works correctly?"
   - "What are the acceptance criteria?"

5. **Constraints & Assumptions**
   - "Any limitations or constraints?"
   - "Dependencies on other work?"

**Key principle:** Ask questions naturally, allowing the discussion to flow. The goal is to gather enough information to write a comprehensive PRD that aligns with the existing project.

### 3. Generate PRD From Brainstorming Discussion

Based on the brainstorming discussion, create comprehensive PRD.

Get current datetime: `date -u +"%Y-%m-%dT%H:%M:%SZ"`

Create file: `./doc/$ARGUMENTS/prds/{feature_name}.md`

**PRD File:** `./doc/$ARGUMENTS/prds/<feature_name>.md`

```markdown
---
name: <feature_name>
description: <one_line_description>
status: backlog
created: [Current ISO datetime]
updated: [Current ISO datetime]
---

# PRD: <feature_name>

## Executive Summary
Brief overview of the feature and its value proposition.

## Problem Statement
What problem does this feature solve?
Why is it needed now?
How does it enhance the existing project?

## Integration with Existing Project
- How does this feature work with existing components?
- What existing code/architecture will it leverage?
- Any modifications needed to current system?

## User Stories
### User Persona 1
- Story 1: As a [user], I want [action], so that [benefit]
- Story 2: As a [user], I want [action], so that [benefit]

### User Persona 2
- Story 1: ...

## Functional Requirements
### Feature 1
- Detailed description
- User interaction flow
- Expected behavior

### Feature 2
- ...

## Non-Functional Requirements
- Performance expectations
- Security requirements
- Scalability needs
- Compatibility requirements

## Technical Approach
- Proposed technology choices
- Integration points with existing code
- Database/storage changes
- API or interface design

## Success Criteria
- [ ] Criterion 1 (measurable)
- [ ] Criterion 2 (measurable)
- [ ] Criterion 3 (measurable)

## Constraints & Assumptions
- Technical limitations
- Timeline constraints
- Resource constraints
- Assumptions about dependencies

## Out of Scope
- Features explicitly NOT included
- Future enhancements deferred
- Known limitations accepted

## Dependencies
- Other features this depends on
- External services/libraries
- Prerequisite work

## Estimated Effort
- Timeline estimate (e.g., 1-2 weeks)
- Resource requirements
- Critical path items
```


### 4. Quality Validation

Before saving the PRD, verify:
- [ ] All sections are complete (no placeholder text)
- [ ] User stories are clear and actionable
- [ ] Requirements are specific and measurable
- [ ] Success criteria are testable
- [ ] Dependencies are identified
- [ ] Integration points with existing project are clear
- [ ] Technical approach is sound

### 5. Save PRD File

Write the PRD to: `./doc/$ARGUMENTS/prds/<feature_name>.md`

Verify file was created successfully:
```bash
[ -f ./doc/$ARGUMENTS/prds/<feature_name>.md ] && echo "✅ PRD file created" || echo "❌ Failed to create PRD"
```

### 6. Update Project Feature List

Read `./doc/$ARGUMENTS/PROJECT-PRD.md` and update the "Feature List" section.

Add a new row to the Feature List table:

```markdown
| <feature_name> | Planned | 0% | Added new feature |
```

Update the `updated` timestamp in PROJECT-PRD.md frontmatter to current datetime.

**Important:** Preserve all existing features and their status in the table.

### 7. Verify and Output

Verify updates:
```bash
grep -q "<feature_name>" ./doc/$ARGUMENTS/PROJECT-PRD.md && echo "✅ Feature list updated"
```

Show confirmation:

```
✅ New PRD Created Successfully

Project: $ARGUMENTS
Feature: <feature_name>
Location: ./doc/$ARGUMENTS/prds/<feature_name>.md

PRD Summary:
- Status: backlog
- Estimated effort: [from brainstorming]
- Key features: [list main features]
- Next step: Parse PRD to epic

Next Steps:
  1. Review the PRD: cat ./doc/$ARGUMENTS/prds/<feature_name>.md
  2. Parse to epic: /pm:prd-parse $ARGUMENTS <feature_name>
  3. Decompose epic: /pm:epic-decompose $ARGUMENTS <feature_name> <epic_name>

Project Feature List Updated:
  - Total features: [count]
  - In development: [count]
  - Completed: [count]
```

## Error Handling

If any step fails:
- Report what succeeded and what failed
- Show which answers were collected before failure
- Allow user to save progress or retry
- Don't corrupt existing files

## Important Notes

- **Questions are asked one at a time** - Wait for user input after each question
- **Use project context** - Reference existing tech stack when asking questions
- **Store all answers** - Use them all in PRD generation, don't skip any
- **No skipping to generation** - Must complete all 20 questions before creating PRD
- **Allow editing** - If user wants to change an answer at Q20, support that
- **Comprehensive output** - PRD should be immediately ready for /pm:prd-parse



## Error Handling

### Project Not Found
```
❌ Project '$ARGUMENTS' not found

Available projects:
  [list from ./doc/]

Create new project first:
  /pm:project-new $ARGUMENTS
```

### Invalid Feature Name
```
❌ Feature name must be kebab-case (lowercase letters, numbers, hyphens)

Examples of valid names:
  - advanced-ui
  - data-export
  - user-authentication
  - real-time-sync
```

### PRD Already Exists
```
⚠️ PRD '<feature_name>' already exists for project '$ARGUMENTS'

Options:
  1. Edit existing: /pm:prd-edit $ARGUMENTS <feature_name>
  2. Use different name: /pm:prd-new $ARGUMENTS (then enter different feature name)
  3. Replace: /pm:prd-new $ARGUMENTS (enter same feature name and confirm overwrite)
```

### File Creation Failed
```
❌ Failed to create PRD file

Possible issues:
  - Permission denied for directory ./doc/$ARGUMENTS/prds/
  - Insufficient disk space
  - Invalid file path

Check permissions:
  ls -la ./doc/$ARGUMENTS/prds/
```

## Workflow Integration

### Full Feature Development Workflow

```
Step 1: Create project (first time only)
  /pm:project-new simple-python-ui
    ↓
Step 2: Add new features (each time you want a new feature)
  /pm:prd-new simple-python-ui  ← ← ← YOU ARE HERE
    ↓
Step 3: Parse PRD to epic
  /pm:prd-parse simple-python-ui <feature_name>
    ↓
Step 4: Decompose epic to tasks
  /pm:epic-decompose simple-python-ui <feature_name> <epic_name>
    ↓
Step 5: Sync to GitHub
  /pm:epic-sync simple-python-ui <feature_name> <epic_name>
    ↓
Step 6: Start development
  /pm:epic-start simple-python-ui <feature_name> <epic_name>
```

## Important Notes

- **Project alignment:** Always ensure new feature integrates well with existing project architecture and goals
- **Context preservation:** Use existing PROJECT-PRD.md to guide feature design
- **Prevent duplication:** Check for existing PRDs to avoid conflicts
- **Update tracking:** Always update PROJECT-PRD.md feature list when creating new PRD
- **Feature naming:** Use kebab-case for consistency with existing project structure
- **Brainstorming quality:** Invest time in thorough brainstorming to create comprehensive requirements
- **No project creation:** This command ONLY creates PRDs for existing projects, never creates new projects
- **Natural discussion:** Conduct brainstorming as a natural conversation, not a rigid questionnaire
- **Project context first:** Always read and understand existing PROJECT-PRD.md before generating new PRD

## Example Workflow

```
User: /pm:prd-new simple-python-ui

System: 
  ✅ Project simple-python-ui found
  ✅ Enter new feature name: uart-comport

User:
  uart-comport

System:
  ✅ Checking for existing PRD... (none found)
  ✅ Reading project context from PROJECT-PRD.md
  
  Starting brainstorming for 'uart-comport' in project 'simple-python-ui'
  
  This project is a PyQt6 desktop application with UI framework.
  
  Let's discuss the new UART communication feature:
  
  "What is the main purpose of this new feature?"
  
User:
  Enable communication with Arduino and other serial devices via COM ports
  
System:
  "How does this extend the existing project?"
  
User:
  Currently the app only has UI components. This adds hardware communication capability.
  
System:
  "Who will be using this feature?"
  
User:
  Mainly developers and hobbyists working with embedded systems
  
[... natural brainstorming conversation continues ...]
  
System:
  ✅ PRD Created: ./doc/simple-python-ui/prds/uart-comport.md
  ✅ Feature list updated in PROJECT-PRD.md
  
  📝 Next: /pm:prd-parse simple-python-ui uart-comport
```

$ARGUMENTS