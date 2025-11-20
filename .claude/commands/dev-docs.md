---
name: dev-docs
description: Create comprehensive development documentation with ULTRATHINK deep planning mode
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

### Step 2.5: ULTRATHINK PHASE 1 - Project Architecture Analysis

**CRITICAL: Trigger Deep Thinking Here**

Prompt Claude:
```
Ultrathink about the complete project architecture, 
technical requirements, and implementation constraints for:

PROJECT: [project-name]
DESCRIPTION: [project-description]

Consider these aspects:
1. What are the core technical challenges?
2. What existing patterns or code should be leveraged?
3. What are the scalability requirements?
4. What are the security considerations?
5. What are the performance constraints?
6. What are the maintainability requirements?

Show your complete thinking process.
```

**What happens**: 
- Claude spends 31,999 tokens thinking deeply
- Analyzes all architectural dimensions
- Considers multiple approaches
- Identifies optimal path forward

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
find . -type f \
  ! -path "*/node_modules/*" \
  ! -path "*/__pycache__/*" \
  ! -path "*/.git/*" \
  ! -path "*/build/*" \
  ! -path "*/dist/*" \
  ! -path "*/target/*" \
  ! -path "*/.venv/*" \
  ! -path "*/.gradle/*" \
  ! -path "*/.maven/*" \
  ! -name "*.o" \
  ! -name "*.a" \
  ! -name "*.so" \
  ! -name "*.dll" \
  ! -name "*.exe" \
  ! -name "*.pyc" \
  ! -name "*.class" \
  ! -name "*.jar" \
  | head -100
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

#### 4e: ULTRATHINK PHASE 2 - Risk & Design Analysis

**CRITICAL: Second Deep Thinking Pass**

Prompt Claude:
```
Ultrathink about the risks, edge cases, and optimal design decisions:

PROJECT: [project-name]
CURRENT ANALYSIS: [summary from Step 2.5]
CODE STRUCTURE: [actual code review from Steps 4a-4d]

Now consider:
1. What are all possible failure points?
2. What edge cases might break this implementation?
3. Are there better architectural approaches?
4. What dependencies could cause problems?
5. What testing strategy would catch issues early?
6. How does this integrate with existing systems?

Compare different implementation approaches and recommend the best one.
```

**What happens**:
- Another 31,999 tokens of deep thinking
- Risk assessment with thorough analysis
- Optimal design decisions identified
- All trade-offs evaluated

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

### Step 6: ULTRATHINK PHASE 3 - Plan Verification

**CRITICAL: Final Deep Thinking Pass**

Prompt Claude:
```
Ultrathink about plan completeness and quality verification:

PROJECT: [project-name]
GENERATED PLAN: [Show the three documents]

Review and verify:
1. Does this plan address ALL identified risks?
2. Are all phases properly sequenced?
3. Are the time estimates realistic?
4. Does this align with best practices?
5. What could we have missed?
6. Is the architecture decision sound?
7. Are there any hidden dependencies?

If you find issues, suggest improvements.
```

**What happens**:
- Final 31,999 tokens verification
- Plan completeness checked
- Quality assurance pass
- Hidden issues surfaced

### Step 7: Save All Three Files

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

### Step 8: Confirm Creation

After creating files, display:
```
✓ Planning mode completed with ULTRATHINK
✓ Project name: [project-name]
✓ Thinking budget used: 95,997 tokens (3 ultrathink passes)
✓ Files created:
  - dev/active/[project-name]/[project-name]-plan.md
  - dev/active/[project-name]/[project-name]-context.md
  - dev/active/[project-name]/[project-name]-tasks.md

PLANNING INSIGHTS:
- Architecture decisions based on deep analysis (Phase 1)
- All risks identified and mitigated (Phase 2)
- Implementation phases optimized (Phase 3)
- Timeline is realistic

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

3. **ULTRATHINK Triggers**
   - Phase 1 (Step 2.5): Project architecture analysis
   - Phase 2 (Step 4e): Risk and design analysis
   - Phase 3 (Step 6): Plan verification
   - Each phase uses 31,999 thinking tokens

4. **User-Friendly Output**
   - Three complete, well-structured documents
   - Clear and actionable
   - Ready for review and approval
   - Professional formatting

5. **Directory Handling**
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
- ✓ Completed 3 ultrathink deep thinking passes

---

## Thinking Budget Summary

```
ULTRATHINK PHASE 1: Project Architecture Analysis
├── Thinking Tokens: 31,999
├── Focus: Architecture, requirements, constraints
└── Output: Deep architectural understanding

ULTRATHINK PHASE 2: Risk & Design Analysis
├── Thinking Tokens: 31,999
├── Focus: Risks, edge cases, optimal design
└── Output: Risk mitigation strategy

ULTRATHINK PHASE 3: Plan Verification
├── Thinking Tokens: 31,999
├── Focus: Completeness, quality, best practices
└── Output: Verified quality plan

TOTAL THINKING BUDGET: 95,997 tokens
EQUIVALENT: ~$0.50 cost
QUALITY LEVEL: Enterprise-grade planning
```

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