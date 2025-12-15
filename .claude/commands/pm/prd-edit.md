---
allowed-tools: Read, Write, LS
---

# PRD Edit

Edit an existing Product Requirements Document.

## Usage
```
/pm:prd-edit <project_name> <feature_name>
```

## Preflight Checklist

Before proceeding, complete these validation steps.

### Input Validation

1. **Verify parameters:**
   - Check if both `<project_name>` and `<feature_name>` were provided
   - If not, tell user: " Parameters missing. Please run: /pm:prd-edit <project_name> <feature_name>"
   - Stop execution if parameters are missing

2. **Verify PRD exists:**
   - Check if `./doc/$project_name/prds/$feature_name.md` exists
   - If not found, tell user: " PRD not found: ./doc/$project_name/prds/$feature_name.md"
   - Suggest: "Create it with: /pm:project-feature $project_name --add $feature_name"
   - Stop execution if PRD doesn't exist

## Instructions

### 1. Read Current PRD

Read `./doc/$project_name/prds/$feature_name.md`:
- Parse frontmatter (name, description, status, created, updated)
- Display current content
- Show all sections

### 2. Interactive Edit

Ask user what sections to edit:
- Executive Summary
- Problem Statement
- User Stories
- Requirements (Functional/Non-Functional)
- Success Criteria
- Constraints & Assumptions
- Out of Scope
- Dependencies

Allow user to select multiple sections to edit:
```
Which sections to edit? (comma-separated or "all")
Example: Executive Summary, User Stories
Or: all
```

### 3. Update PRD

Get current datetime: `date -u +"%Y-%m-%dT%H:%M:%SZ"`

Update PRD file `./doc/$project_name/prds/$feature_name.md`:
- Preserve frontmatter except `updated` field
- Apply user's edits to selected sections
- Update `updated` field with current datetime
- Keep `created` field unchanged
- Keep `status` field unchanged

### 4. Check Epic Impact

Check if PRD has associated epic:
```bash
epic_file="./doc/$project_name/epics/$feature_name/epic.md"
if [ -f "$epic_file" ]; then
  echo " This PRD has associated epic: $feature_name"
  echo "Epic may need updating based on PRD changes."
  echo ""
  echo "Review epic? (yes/no)"
  read -r review_epic
  
  if [ "$review_epic" = "yes" ]; then
    echo "Review with: /pm:prd-parse $project_name $feature_name"
  fi
fi
```

### 5. Output

```
 Updated PRD: ./doc/$project_name/prds/$feature_name.md

Sections edited:
  - Executive Summary
  - User Stories

Last updated: {current_datetime}

 Associated epic found: $feature_name
   Review changes with: /pm:prd-parse $project_name $feature_name

Next steps:
  - Update epic: /pm:prd-parse $project_name $feature_name
  - View PRD: cat ./doc/$project_name/prds/$feature_name.md
```

## Error Handling

If any step fails:
- Clearly explain what went wrong
- Provide specific steps to fix the issue
- Never leave partial or corrupted files
- Create backup before editing

## Important Notes

- Preserve original `created` date
- Always update `updated` timestamp
- Follow `/rules/frontmatter-operations.md`
- Create `.md.backup` before making changes
- Validate frontmatter after edit

## Frontmatter Guidelines

Example before:
```yaml
---
name: ui
description: Dashboard UI components
status: backlog
created: 2025-01-10T10:30:00Z
updated: 2025-01-10T10:30:00Z
---
```

Example after (only `updated` changes):
```yaml
---
name: ui
description: Dashboard UI components
status: backlog
created: 2025-01-10T10:30:00Z
updated: 2025-01-15T14:45:00Z
---
```