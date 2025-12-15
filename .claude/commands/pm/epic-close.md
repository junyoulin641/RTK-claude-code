---
allowed-tools: Bash, Read, Write, LS
---

# Epic Close

Mark an epic as complete when all tasks are done.

## Usage
```
/pm:epic-close <project_name> <feature_name> <epic_name>
```

## Required Rules

**IMPORTANT:** Before executing this command, read and follow:
- `.claude/rules/datetime.md` - For getting real current date/time

## Preflight Checklist

Before proceeding, complete these validation steps.

1. **Verify parameters:**
   - Check if all three `<project_name>`, `<feature_name>`, `<epic_name>` were provided
   - If not, tell user: " Parameters missing. Please run: /pm:epic-close <project_name> <feature_name> <epic_name>"
   - Stop execution if parameters are missing

2. **Verify epic exists:**
   - Check if `./doc/$project_name/epics/$feature_name/$epic_name.md` exists
   - If not found, tell user: " Epic not found: ./doc/$project_name/epics/$feature_name/$epic_name.md"
   - Stop execution if epic doesn't exist

## Instructions

### 1. Verify All Tasks Complete

Check all task files in `./doc/$project_name/epics/$feature_name/$epic_name/`:
- Verify all have `status: closed` in frontmatter
- Count total tasks and completed tasks
- If any open tasks found: " Cannot close epic. Open tasks remain: {list}"
- Stop execution if any tasks are still open

Show summary:
```
Tasks status:
  Total: {count}
  Closed: {closed_count}
  Open: {open_count}
```

### 2. Update Epic Status

Get current datetime: `date -u +"%Y-%m-%dT%H:%M:%SZ"`

Update `./doc/$project_name/epics/$feature_name/$epic_name.md` frontmatter:
```yaml
status: completed
progress: 100%
updated: {current_datetime}
completed: {current_datetime}
```

### 3. Update PRD Status

Check if PRD exists at `./doc/$project_name/prds/$feature_name.md`:
- If found, update frontmatter status to "implemented"
- Update `updated` field with current datetime
- Confirm: "Updated PRD status to 'implemented'"

### 4. Close Epic on GitHub

If epic has GitHub issue URL in frontmatter:
```bash
# Get GitHub issue number from github: field
github_url=$(grep "^github:" ./doc/$project_name/epics/$feature_name/$epic_name.md | sed 's/^github: *//')
issue_num=$(echo "$github_url" | grep -o '/[0-9]*$' | tr -d '/')

if [ -n "$issue_num" ]; then
  # Get repo
  remote_url=$(git remote get-url origin 2>/dev/null || echo "")
  REPO=$(echo "$remote_url" | sed 's|.*github.com[:/]||' | sed 's|\.git$||')
  
  gh issue close "$issue_num" --repo "$REPO" --comment " Epic completed - all tasks done"
fi
```

### 5. Archive Option

Ask user: "Archive completed epic? (yes/no)"

If yes:
```bash
# Create archive directory
mkdir -p ./doc/$project_name/epics/$feature_name/.archived/

# Move epic directory
mv ./doc/$project_name/epics/$feature_name/$epic_name/ ./doc/$project_name/epics/$feature_name/.archived/$epic_name/

# Create archive summary
cat > ./doc/$project_name/epics/$feature_name/.archived/$epic_name/ARCHIVED.md << EOF
# Archived Epic: $epic_name

**Completed**: {current_datetime}
**Total tasks**: {task_count}
**Duration**: {days from created to completed} days

## Task Summary
- All tasks completed
- Epic status: completed
- Progress: 100%

See epic.md for full details.
EOF
```

If no:
```
Epic will remain in active directory.
Archive manually with: mv ./doc/$project_name/epics/$feature_name/$epic_name ./doc/$project_name/epics/$feature_name/.archived/
```

### 6. Calculate Duration

```bash
created_date=$(grep "^created:" ./doc/$project_name/epics/$feature_name/$epic_name.md | sed 's/^created: *//')
completed_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Calculate days (rough estimate)
created_epoch=$(date -d "$created_date" +%s 2>/dev/null || echo "0")
completed_epoch=$(date -d "$completed_date" +%s 2>/dev/null || echo "0")

if [ "$created_epoch" -gt 0 ] && [ "$completed_epoch" -gt 0 ]; then
  days=$(( (completed_epoch - created_epoch) / 86400 ))
else
  days="unknown"
fi
```

### 7. Output

```
 Epic Closed: $epic_name
   Project: $project_name
   Feature: $feature_name

 Summary:
  Total tasks: {count}
  Completed: {count}
  Duration: {days} days
  
{If has GitHub}: GitHub issue #{number} closed
{If archived}: Archived to: ./doc/$project_name/epics/$feature_name/.archived/$epic_name/

 Updates:
   Epic status: completed → 100%
   PRD status: implemented
  {If archived}:  Archived
  {If GitHub}:  GitHub issue closed

Next steps:
  - View archived epic: /pm:epic-show $project_name $feature_name $epic_name
  - Or work on next feature: /pm:project-status $project_name
```

## Error Handling

If any step fails:
- Report which tasks are still open (if verification fails)
- Show which updates succeeded before failure
- Provide option to retry or skip archive step

## Important Notes

- Only close epics with ALL tasks complete
- Preserve all data when archiving (don't delete)
- Update related PRD status automatically
- Keep completion date in archive summary
- GitHub issue should be closed for record-keeping