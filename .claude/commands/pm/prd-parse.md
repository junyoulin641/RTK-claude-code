---
allowed-tools: Bash, Read, Write, LS
---

# PRD Parse

Convert PRD to technical implementation epic(s).

## Usage
```
/pm:prd-parse <project_name> <feature_name>
```

## Required Rules

**IMPORTANT:** Before executing this command, read and follow:
- `.claude/rules/datetime.md` - For getting real current date/time

## Preflight Checklist

Before proceeding, complete these validation steps.
Do not bother the user with preflight checks progress ("I'm not going to ..."). Just do them and move on.

### Validation Steps

1. **Verify parameters:**
   - Check if both `<project_name>` and `<feature_name>` were provided
   - If not, tell user: " Parameters missing. Please run: /pm:prd-parse <project_name> <feature_name>"
   - Stop execution if parameters are missing

2. **Verify PRD exists:**
   - Check if `./doc/$project_name/prds/$feature_name.md` exists
   - If not found, tell user: " PRD not found: ./doc/$project_name/prds/$feature_name.md"
   - Suggest: "First create it with: /pm:project-feature $project_name --add $feature_name"
   - Stop execution if PRD doesn't exist

3. **Validate PRD frontmatter:**
   - Verify PRD has valid frontmatter with: name, description, status, created
   - If frontmatter is invalid or missing, tell user: " Invalid PRD frontmatter. Please check: ./doc/$project_name/prds/$feature_name.md"
   - Show what's missing or invalid

4. **Check for existing epics:**
   - Check if any epic files already exist in `./doc/$project_name/epics/$feature_name/`
   - If epics exist, ask user: " Epic(s) for '$feature_name' already exist. Overwrite? (yes/no)"
   - Only proceed with explicit 'yes' confirmation
   - If user says no, suggest: "View existing epics with: /pm:epic-show $project_name $feature_name {epic_name}"

5. **Verify directory permissions:**
   - Ensure `./doc/$project_name/epics/$feature_name/` directory exists or can be created
   - If cannot create, tell user: " Cannot create epic directory. Please check permissions."

## Instructions

You are a technical architect analyzing a Product Requirements Document and deciding how to split it into epics for: **$feature_name** in project **$project_name**

### 1. Read and Analyze the PRD

- Load the PRD from `./doc/$project_name/prds/$feature_name.md`
- Analyze all requirements and constraints
- Understand the user stories and success criteria
- Extract the PRD description from frontmatter
- Identify major functional areas and components

### 2. Decide Epic Split Strategy

Analyze the PRD and decide:
- Should this be **1 Epic** or **Multiple Epics**?
- If multiple, identify the natural boundaries between them
- Use these criteria:
  - **Technical layers**: Frontend, Backend, Infrastructure as separate epics
  - **Functional areas**: User Auth, Data Display, Reporting as separate epics
  - **Team boundaries**: If different teams own different areas
  - **Dependencies**: Sequential work should be in separate epics
  - **Timeline**: If some features can ship independently

**Guidelines**:
- Aim for 1-4 epics per feature (rarely more than 4)
- Each epic should be completable in 1-4 weeks
- Keep related functionality together when possible

### 3. Generate Epic Names

For each epic, generate a descriptive name that:
- Is kebab-case: `epic-dashboard`, `epic-authentication`, `epic-real-time-charts`
- Clearly indicates the functional area
- Is short but descriptive (2-3 words)

Examples:
```
PRD: User Dashboard System
  ├─ epic-auth-system → User authentication & authorization
  ├─ epic-dashboard-ui → Dashboard layout & components
  ├─ epic-data-sync → Real-time data synchronization
  └─ epic-export-feature → Data export functionality
```

### 4. Create Epic Files and Directories

For each epic, you MUST create BOTH:
1. Epic definition file: `./doc/$project_name/epics/$feature_name/{epic_name}.md`
2. Epic tasks directory: `./doc/$project_name/epics/$feature_name/{epic_name}/`

```bash
# Create feature directory first
mkdir -p ./doc/$project_name/epics/$feature_name/

# For each epic, create file and directory together
for epic_name in epic-auth epic-dashboard epic-charts; do
  # Create the epic definition file
  touch ./doc/$project_name/epics/$feature_name/${epic_name}.md
  
  # Create the tasks directory
  mkdir -p ./doc/$project_name/epics/$feature_name/${epic_name}/
done
```

Create the epic definition file at: `./doc/$project_name/epics/$feature_name/{epic_name}.md` with this structure:

```markdown
---
name: {epic_name}
status: backlog
created: [Current ISO date/time]
progress: 0%
prd: ./doc/$project_name/prds/$feature_name.md
github: [Will be updated when synced to GitHub]
---

# Epic: {epic_name}

## Overview
Brief technical summary of the implementation approach for this epic.
What this epic delivers and why it's important.

## Architecture Decisions
- Key technical decisions and rationale
- Technology choices for this epic
- Design patterns to use
- Integration points with other epics

## Technical Approach
### Component/Service 1
- Purpose and responsibilities
- Key methods or endpoints
- Data structures

### Component/Service 2
- Purpose and responsibilities
- Key methods or endpoints
- Data structures

### etc.

## Implementation Strategy
- Development phases within this epic
- Risk mitigation strategies
- Testing approach (unit, integration, e2e)

## Task Breakdown Preview
High-level task categories that will be created:
- [ ] Setup & Infrastructure: Description
- [ ] Core Implementation: Description
- [ ] Integration: Description
- [ ] Testing & QA: Description
- [ ] Documentation: Description

## Dependencies
- Dependencies on other epics (if any)
- External service dependencies
- Prerequisite work that must complete first

## Success Criteria (Technical)
- Functional requirements met
- Performance requirements
- Code quality standards (test coverage, etc.)
- Documentation completed

## Estimated Effort
- Timeline estimate for this epic (e.g., 2 weeks)
- Resource requirements
- Critical path items
```

### 5. Frontmatter Guidelines

For all epic files:
- **name**: Use the epic name in kebab-case (same as filename without .md)
- **status**: Always start with "backlog" for new epics
- **created**: Get REAL current datetime by running: `date -u +"%Y-%m-%dT%H:%M:%SZ"`
  - Never use placeholder text
  - Must be actual system time in ISO 8601 format
- **progress**: Always start with "0%" for new epics
- **prd**: Reference the source PRD file path: `./doc/$project_name/prds/$feature_name.md`
- **github**: Leave placeholder text - will be updated during sync

### 6. Directory Structure

Create the complete directory structure for each epic:

```bash
# Create feature epics directory
mkdir -p ./doc/$project_name/epics/$feature_name/

# For each epic, create both file and directory
mkdir -p ./doc/$project_name/epics/$feature_name/epic-auth/
touch ./doc/$project_name/epics/$feature_name/epic-auth.md

mkdir -p ./doc/$project_name/epics/$feature_name/epic-dashboard/
touch ./doc/$project_name/epics/$feature_name/epic-dashboard.md

mkdir -p ./doc/$project_name/epics/$feature_name/epic-charts/
touch ./doc/$project_name/epics/$feature_name/epic-charts.md
```

Structure created:
```
./doc/$project_name/epics/$feature_name/
├── epic-auth.md                    ← Epic definition file
├── epic-auth/                      ← Tasks directory (will hold 001.md, 002.md, etc.)
│   ├── execution-status.md
│   └── (will contain task files after decompose)
│
├── epic-dashboard.md               ← Epic definition file
├── epic-dashboard/                 ← Tasks directory
│   ├── execution-status.md
│   └── (will contain task files after decompose)
│
├── epic-charts.md                  ← Epic definition file
└── epic-charts/                    ← Tasks directory
    ├── execution-status.md
    └── (will contain task files after decompose)
```

Files created:
- `./doc/$project_name/epics/$feature_name/epic-auth.md`
- `./doc/$project_name/epics/$feature_name/epic-dashboard.md`
- `./doc/$project_name/epics/$feature_name/epic-charts.md`
- etc.

Directories created (for future task files):
- `./doc/$project_name/epics/$feature_name/epic-auth/`
- `./doc/$project_name/epics/$feature_name/epic-dashboard/`
- `./doc/$project_name/epics/$feature_name/epic-charts/`
- etc.

### 7. Quality Validation

Before saving epics, verify:
- [ ] Each PRD requirement is addressed in at least one epic
- [ ] Task breakdown categories are realistic
- [ ] Dependencies between epics are accurate
- [ ] Effort estimates are reasonable
- [ ] Architecture decisions are justified
- [ ] Total number of epics is 1-4 (rarely more)
- [ ] Each epic can be completed independently or with clear dependencies

### 8. Post-Creation

After successfully creating epic(s), verify all directories were created:

```bash
# Verify files exist
ls -la ./doc/$project_name/epics/$feature_name/epic-*.md

# Verify directories exist
ls -d ./doc/$project_name/epics/$feature_name/epic-*/
```

Output:
```
 Epic(s) created from PRD: $feature_name
   Project: $project_name

 Directory Structure Created:
   ./doc/$project_name/epics/$feature_name/
   ├── epic-auth.md + epic-auth/ directory
   ├── epic-dashboard.md + epic-dashboard/ directory
   ├── epic-charts.md + epic-charts/ directory
   └── epic-export.md + epic-export/ directory

 Summary:
  - Feature: $feature_name
  - Total epics created: {count}
  - Epics:
    {list each epic with estimated timeline}

 Next Steps:
  For each epic, decompose into tasks:
  /pm:epic-decompose $project_name $feature_name epic-auth
  /pm:epic-decompose $project_name $feature_name epic-dashboard
  /pm:epic-decompose $project_name $feature_name epic-charts
  /pm:epic-decompose $project_name $feature_name epic-export
  
  Or to see an epic:
  /pm:epic-show $project_name $feature_name epic-auth
```

## Decision Guidelines

### When to Create 1 Epic
- Small feature (< 2 weeks effort)
- No clear functional boundaries
- Single technical layer (all frontend OR all backend)
- Tight coupling between components

### When to Create 2-3 Epics
- Medium feature (2-4 weeks effort)
- Clear separation (Frontend + Backend)
- Or functional split (Auth + Features)
- Can have one epic depend on another

### When to Create 4+ Epics
- Large feature (4+ weeks effort)
- Multiple independent functional areas
- Different teams working in parallel
- Clean architectural layers to split on

## Error Recovery

If any step fails:
- Clearly explain what went wrong
- If PRD is incomplete, list specific missing sections
- If technical approach is unclear, identify what needs clarification
- Never create epics with incomplete information

## IMPORTANT:
- Aim for simplicity: fewer, larger epics are often better than many small ones
- When creating epics, identify ways to simplify and improve
- Look for ways to leverage existing functionality instead of creating new code
- Focus on technical clarity and team coordination