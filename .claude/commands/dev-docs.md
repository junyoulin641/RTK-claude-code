---
name: dev-docs
description: Create comprehensive development documentation in planning mode
---

# Development Documentation Creator

## Overview
Creates three comprehensive markdown documents for project planning:
- **plan.md**: Complete project plan with phases, tasks, risks, and timeline
- **context.md**: Project background, architecture, and key decisions
- **tasks.md**: Detailed task checklist with progress tracking

## How to Use
```
/dev-docs
```

User will be prompted to provide:
1. Project name
2. Project description

## Workflow

### Step 1: Project Information Collection
Ask user for:
- **Project Name**: (e.g., json-migration, web-ui-dashboard)
- **Project Description**: (e.g., "Migrate LOG format from plain text to JSON")

### Step 2: Check if Project Already Exists
```bash
check if dev/active/[project-name]/ exists
```

If exists:
- Ask user: "Project '[project-name]' already exists. What would you like to do?"
  - Option A: "Create new version (e.g., json-migration-v2)"
  - Option B: "Update existing project"
  - Option C: "Cancel and choose different name"

### Step 3: Create Directory Structure
```bash
mkdir -p dev/active/[project-name]
```

### Step 4: Enter PLANNING MODE
**CRITICAL: Do NOT write any code in this step**

Perform thorough analysis:

#### 4a: Analyze Project Structure
Execute:
```bash
ls -la
pwd
find . -type f -name "*.py" -o -name "*.tsx" -o -name "*.ts" -o -name "*.json" | grep -v node_modules | grep -v __pycache__ | head -50
```

Understand:
- Overall project structure
- Number and types of files
- Existing code organization

#### 4b: Review Existing Code
Look for and examine:
- `package.json` or `requirements.txt` (understand dependencies)
- `README.md` (understand project purpose)
- `.env` or `config` files (understand configuration)
- Existing source files (first 50-100 lines to understand architecture)
- Existing documentation

#### 4c: Understand Current Architecture
Based on code analysis, document:
- What already exists
- How the current system works
- What technologies are used
- What the current limitations are

#### 4d: Analyze Requirements
Based on user's description:
- What needs to be built/changed
- What are the main goals
- What are the constraints

### Step 5: Generate Three Documents

#### Document 1: [project-name]-plan.md

**Purpose**: Complete project plan with all details

**Required Sections**:

```markdown
# [Project Name] - Implementation Plan

## Executive Summary
- What is this project
- Why we're building it
- High-level goals
- Estimated scope and duration

## Current State
- What exists now
- Current architecture
- Current limitations
- What we're starting from

## Implementation Phases

### Phase 1: [Phase Name] (Estimated X days)
Brief description of what this phase accomplishes

#### Phase 1 Tasks:
- **Task 1.1**: [Task Name]
  - Description: [What needs to be done]
  - Acceptance Criteria:
    - [ ] Criterion 1
    - [ ] Criterion 2
  - Dependencies: [Other tasks it depends on]
  - Estimated Time: X hours

- **Task 1.2**: [Task Name]
  - [Same structure as 1.1]

### Phase 2: [Phase Name] (Estimated X days)
[Same structure as Phase 1]

### Phase N: ...

## Risk Assessment

| Risk | Impact | Likelihood | Mitigation Strategy |
|------|--------|------------|-------------------|
| [Risk 1] | [High/Med/Low] | [High/Med/Low] | [How to handle] |
| [Risk 2] | | | |

## Success Criteria
- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]
- [ ] [Measurable criterion 3]

## Timeline
- Phase 1: [Expected dates]
- Phase 2: [Expected dates]
- Total estimated duration: X weeks
```

**Guidelines**:
- Be comprehensive but concise
- Include enough detail for Claude to understand the full scope
- Estimate time realistically
- Identify and plan for risks
- No length limit - be thorough

---

#### Document 2: [project-name]-context.md

**Purpose**: Background information and key decisions

**Required Sections**:

```markdown
# Context - [Project Name]

## Project Background
- Why this project exists
- Business/technical motivation
- Who it serves or what problem it solves

## Key File Locations

### Backend Files
- backend/src/... - [Brief description]
- backend/config/... - [Brief description]

### Frontend Files
- src/components/... - [Brief description]
- src/pages/... - [Brief description]

### Configuration
- package.json - [Key dependencies]
- .env - [Key environment variables]
- docker-compose.yml - [If applicable]

### Documentation
- README.md - [Current status]
- docs/ - [Any existing documentation]

## Current Architecture

### System Overview
[Description of how the current system works]

### Technology Stack
- Backend: [Framework/Language and version]
- Frontend: [Framework/Language and version]
- Database: [Type and version if applicable]
- Other tools: [Any other relevant tech]

### Existing Features/Functionality
[What the system currently does]

### Current Limitations
[What doesn't work or what's missing]

## Architecture Decisions
[Document any significant decisions about how to structure the implementation]

- **Decision 1**: [What was decided and why]
- **Decision 2**: [What was decided and why]

## Key Constraints
- Performance: [Any performance requirements]
- Compatibility: [Any compatibility needs]
- Security: [Any security requirements]
- Scalability: [Any scalability considerations]

## Dependencies
[What this project depends on]
- [Dependency 1]: [How it's used]
- [Dependency 2]: [How it's used]

## Next Session Starting Point
[If this is a continuation, document where to start]
- Last completed: [Which tasks/phases]
- Next to do: [Which task should be started]
- Current blockers: [Any issues to be aware of]
```

**Guidelines**:
- Practical and reference-oriented
- Include actual file paths from the codebase
- Document decisions for future reference
- No length limit - be thorough but focused

---

#### Document 3: [project-name]-tasks.md

**Purpose**: Detailed task checklist with progress tracking

**Required Sections**:

```markdown
# Task Checklist - [Project Name]

**Project**: [Project Name]
**Status**: Planning
**Last Updated**: [Today's date]

## Phase 1: [Phase Name]

### Task 1.1: [Task Name]
- [ ] **Status**: [ ] Not Started | [ ] In Progress | [ ] Completed
- **Acceptance Criteria**:
  - [ ] Criterion 1
  - [ ] Criterion 2
- **Dependencies**: [If any]
- **Estimated Time**: X hours
- **Actual Time**: ___ hours
- **Notes**: [Any notes about this task]

### Task 1.2: [Task Name]
[Same structure as 1.1]

---

## Phase 2: [Phase Name]

### Task 2.1: [Task Name]
[Same structure]

---

## Progress Summary

### Phase 1
| Item | Count |
|------|-------|
| Total Tasks | X |
| Completed | 0 |
| In Progress | 0 |
| Not Started | X |
| **Progress** | **0%** |

### Phase 2
[Same as Phase 1]

### Overall
| Item | Count |
|------|-------|
| Total Tasks | X |
| Completed | 0 |
| In Progress | 0 |
| Not Started | X |
| **Overall Progress** | **0%** |

## Critical Path Analysis
[Which tasks are on the critical path - blocking other tasks]

### Task Dependencies
- Task 1.1 → blocks → Task 1.2
- Task 1.2 → blocks → Task 2.1
[Document the chain of dependencies]

## Notes
[Any general notes about the project]
```

**Guidelines**:
- Clear status tracking
- Detailed acceptance criteria
- Clear dependencies
- No length limit - be thorough

---

### Step 6: Save All Three Files

Create files in: `dev/active/[project-name]/`

Files to create:
- `[project-name]-plan.md`
- `[project-name]-context.md`
- `[project-name]-tasks.md`

Example:
```
For project "json-migration", create:
dev/active/json-migration/
├── json-migration-plan.md
├── json-migration-context.md
└── json-migration-tasks.md
```

### Step 7: Confirm Creation

After creating files, display:
```
✓ Planning mode completed
✓ Project name: [project-name]
✓ Files created:
  - dev/active/[project-name]/[project-name]-plan.md
  - dev/active/[project-name]/[project-name]-context.md
  - dev/active/[project-name]/[project-name]-tasks.md

Next steps:
1. Review the three documents
2. Make any necessary changes
3. Say "Execute plan" when ready to start development
4. Or say "Update plan" if you want to make changes
```

---

## Important Rules

1. **PLANNING MODE ONLY**
   - Do NOT write any code
   - Do NOT implement anything
   - Do NOT modify existing files
   - Only analyze and document

2. **Thorough Analysis**
   - Spend time understanding the project
   - Don't rush the planning
   - Be comprehensive
   - Think through risks and challenges

3. **User-Friendly Output**
   - Three complete, well-structured documents
   - Clear and actionable
   - Ready for review and approval
   - Professional formatting

4. **Directory Handling**
   - Check if project exists
   - Ask user what to do if it does
   - Create directory if it doesn't exist
   - Never silently overwrite

---

## Error Handling

### If user provides invalid input:
- Ask for clarification
- Explain what information is needed

### If project analysis fails:
- Explain what went wrong
- Suggest alternative approaches
- Ask if user wants to continue with manual input

### If cannot create directory:
- Explain the permission issue
- Suggest checking dev/ folder exists
- Offer to use different location

---

## Success Indicators

When /dev-docs completes successfully:
- ✓ Analyzed project structure thoroughly
- ✓ Examined existing code and documentation
- ✓ Generated realistic time estimates
- ✓ Identified potential risks
- ✓ Documented architecture decisions
- ✓ Created three well-organized markdown files
- ✓ Files saved to correct location
- ✓ Ready for user review

---

## Next Commands

After /dev-docs is approved by user:

### /execute-plan
When user is ready to start development:
- Begin implementing tasks from plan
- Use code-format skill automatically
- Update tasks.md as progress is made

### /update-dev-docs
When context is running low (85%+):
- Save progress to markdown files
- Update task status
- Document any new decisions
- Clear context to continue working

### /continue
In new session:
- Load dev/active/[project-name]/ files
- Understand full context
- Continue from where you left off
