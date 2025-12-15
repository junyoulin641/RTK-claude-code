---
allowed-tools: Read, Write, LS
---

# Epic Edit

Edit epic details after creation.

## Usage
```
/pm:epic-edit <project_name> <feature_name> <epic_name>
```

## Required Rules

**IMPORTANT:** Before executing this command, read and follow:
- `.claude/rules/datetime.md` - For getting real current date/time

## Preflight Checklist

Before proceeding, complete these validation steps.

1. **Verify parameters:**
   - Check if all three `<project_name>`, `<feature_name>`, `<epic_name>` were provided
   - If not, tell user: " Parameters missing. Please run: /pm:epic-edit <project_name> <feature_name> <epic_name>"
   - Stop execution if parameters are missing

2. **Verify epic exists:**
   - Check if `./doc/$project_name/epics/$feature_name/$epic_name.md` exists
   - If not found, tell user: " Epic not found: ./doc/$project_name/epics/$feature_name/$epic_name.md"
   - Stop execution if epic doesn't exist

## Instructions

### 1. Read Current Epic

Read `./doc/$project_name/epics/$feature_name/$epic_name.md`:
- Parse frontmatter (name, status, created, updated, prd, github)
- Display current content sections
- Show which sections can be edited

### 2. Interactive Edit

Ask user what to edit:
- Overview
- Architecture Decisions
- Technical Approach (Frontend, Backend, Infrastructure)
- Implementation Strategy
- Task Breakdown Preview
- Dependencies
- Success Criteria
- Estimated Effort

Allow user to select multiple sections or "all":
```
Which sections to edit? (comma-separated or "all")
Example: Architecture Decisions, Technical Approach
Or: all
```

### 3. Update Epic File

Get current datetime: `date -u +"%Y-%m-%dT%H:%M:%SZ"`

Update `./doc/$project_name/epics/$feature_name/$epic_name.md`:
- Preserve all frontmatter except `updated` field
- Apply user's edits to selected content sections
- Update `updated` field with current datetime
- Keep `created`, `name`, `prd`, `github` fields unchanged

### 4. Option to Update GitHub

If epic has GitHub URL in frontmatter:
Ask: "Update GitHub issue? (yes/no)"

If yes:
```bash
epic_file="./doc/$project_name/epics/$feature_name/$epic_name.md"

# Extract GitHub URL and issue number
github_url=$(grep "^github:" "$epic_file" | sed 's/^github: *//')
issue_num=$(echo "$github_url" | grep -o '/[0-9]*$' | tr -d '/')

if [ -n "$issue_num" ]; then
  # Get repo
  remote_url=$(git remote get-url origin 2>/dev/null || echo "")
  REPO=$(echo "$remote_url" | sed 's|.*github.com[:/]||' | sed 's|\.git$||')
  
  # Extract body without frontmatter
  sed '1,/^---$/d; 1,/^---$/d' "$epic_file" > /tmp/epic-body.md
  
  # Update GitHub issue
  gh issue edit "$issue_num" --repo "$REPO" --body-file /tmp/epic-body.md
fi
```

### 5. Output

```
 Updated Epic: $epic_name
   Project: $project_name
   Feature: $feature_name

 Sections edited:
  - Architecture Decisions
  - Technical Approach
  
 Updated: {current_datetime}

{If GitHub updated}:  GitHub issue updated
{If not GitHub}: Note: Epic not yet synced to GitHub
              Run /pm:epic-sync $project_name $feature_name $epic_name to sync

View epic: /pm:epic-show $project_name $feature_name $epic_name
```

## Error Handling

If any step fails:
- Report which updates succeeded/failed
- Show which sections were modified before failure
- Provide option to retry GitHub update separately

## Important Notes

- Preserve all frontmatter history (created date, GitHub URL, etc.)
- Don't change task files when editing epic
- Only update the `updated` timestamp in frontmatter
- Keep `name`, `status`, `created`, `prd`, `github` fields unchanged
- Follow `/rules/frontmatter-operations.md`
- Create backup before making changes