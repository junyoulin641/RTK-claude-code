---
allowed-tools: Bash, Read, Write, LS
---

# Project New

Initialize a new project and create its first PRD through guided brainstorming.

## Usage
```
/pm:project-new <project_name>
```

## Required Rules

**IMPORTANT:** Before executing this command, read and follow:
- `.claude/rules/datetime.md` - For getting real current date/time

## Preflight Checklist

Before proceeding, complete these validation steps.
Do not bother the user with preflight checks progress ("I'm not going to ..."). Just do them and move on.

### Input Validation

1. **Validate project name format:**
   - Must contain only lowercase letters, numbers, and hyphens
   - Must start with a letter
   - No spaces or special characters allowed
   - If invalid, tell user: " Project name must be kebab-case (lowercase letters, numbers, hyphens only). Examples: smart-dashboard, data-platform, payment-system"

2. **Check for existing project:**
   - Check if `./doc/$ARGUMENTS/` directory already exists
   - If it exists, ask user: " Project '$ARGUMENTS' already exists. Do you want to overwrite it? (yes/no)"
   - Only proceed with explicit 'yes' confirmation
   - If user says no, suggest: "Use a different name or run: /pm:project-status $ARGUMENTS to view existing project"

3. **Verify directory structure:**
   - Check if `./doc/` directory exists
   - Create the project directory: `./doc/$ARGUMENTS/`
   - Create prds subdirectory: `./doc/$ARGUMENTS/prds/`
   - If unable to create, tell user: " Cannot create project directory. Please manually create: ./doc/$ARGUMENTS/"

## Instructions

You are a product manager creating a new project and its initial PRD: **$ARGUMENTS**

### 1. Create Project Directory Structure

```bash
mkdir -p ./doc/$ARGUMENTS/prds/
mkdir -p ./doc/$ARGUMENTS/epics/
mkdir -p ./doc/$ARGUMENTS/updates/
```

Verify all directories were created successfully.

### 2. Create PROJECT-PRD.md

Create file: `./doc/$ARGUMENTS/PROJECT-PRD.md`

**Template:**
```markdown
---
name: $ARGUMENTS
version: 1.0
created: [Current ISO date/time]
last_updated: [Current ISO date/time]
---

# PROJECT-PRD: $ARGUMENTS

## Project Overview
[Brief description of the entire project]

## Feature List

| Feature | Status | Progress | Notes |
|---------|--------|----------|-------|
| [Feature 1] | Planned | 0% | - |

## Version History
- v1.0: Project initialized ([current_date])
```

Save this file automatically.

### 3. Launch PRD Brainstorming

You are now a product manager creating a comprehensive Product Requirements Document for the **initial feature** of project "$ARGUMENTS".

Follow this structured approach:

#### Discovery & Context
- Ask clarifying questions about the project "$ARGUMENTS"
- Understand the problem being solved
- Identify target users and use cases
- Gather constraints and requirements

#### PRD Structure
Create a comprehensive PRD with these sections:

**Executive Summary**
- Brief overview and value proposition

**Problem Statement**
- What problem are we solving?
- Why is this important now?

**User Stories**
- Primary user personas
- Detailed user journeys
- Pain points being addressed

**Requirements**

Functional Requirements:
- Core features and capabilities
- User interactions and flows

Non-Functional Requirements:
- Performance expectations
- Security considerations
- Scalability needs

**Success Criteria**
- Measurable outcomes
- Key metrics and KPIs

**Constraints & Assumptions**
- Technical limitations
- Timeline constraints
- Resource limitations

**Out of Scope**
- What we're explicitly NOT building

**Dependencies**
- External dependencies
- Internal team dependencies

### 4. Generate Initial Feature PRD

Based on brainstorming, create the initial feature PRD.

Get current datetime: `date -u +"%Y-%m-%dT%H:%M:%SZ"`

**Determine feature_name** from the brainstorming:
- Should be kebab-case
- Should represent the main initial feature
- Example: if project is "smart-dashboard", feature_name might be "ui" or "core-ui"

Save the PRD file: `./doc/$ARGUMENTS/prds/{feature_name}.md`

With this exact structure:

```markdown
---
name: {feature_name}
description: [Brief one-line description of the PRD]
status: backlog
created: [Current ISO date/time]
---

# PRD: {feature_name}

## Executive Summary
[Content...]

## Problem Statement
[Content...]

[Continue with all sections...]
```

### 5. Quality Checks

Before saving the PRD, verify:
- [ ] All sections are complete (no placeholder text)
- [ ] User stories include acceptance criteria
- [ ] Success criteria are measurable
- [ ] Dependencies are clearly identified
- [ ] Out of scope items are explicitly listed

### 6. Post-Creation Summary

```
 Project initialized: $ARGUMENTS

Directory structure:
  ./doc/$ARGUMENTS/
  ├── PROJECT-PRD.md (created)
  ├── prds/
  │   └── {feature_name}.md (created)
  ├── epics/
  └── updates/

Files created:
   ./doc/$ARGUMENTS/PROJECT-PRD.md
   ./doc/$ARGUMENTS/prds/{feature_name}.md

 Summary:
  - Project name: $ARGUMENTS
  - Initial feature: {feature_name}
  - PRD location: ./doc/$ARGUMENTS/prds/{feature_name}.md

 Next Steps:
1. Update ./doc/$ARGUMENTS/PROJECT-PRD.md with feature status
2. Run: /pm:prd-parse {project_name} {feature_name}
3. (Note: Use project_name=$ARGUMENTS for subsequent commands)
```

## Error Recovery

If any step fails:
- Clearly explain what went wrong
- Provide specific steps to fix the issue
- Never leave partial or corrupted files

Conduct a thorough brainstorming session before writing the PRD. Ask questions, explore edge cases, and ensure comprehensive coverage of the feature requirements for the initial feature of "$ARGUMENTS".

$ARGUMENTS
