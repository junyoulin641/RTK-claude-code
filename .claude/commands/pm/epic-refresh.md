---
allowed-tools: Read, Write, LS
---

# Epic Refresh

Update epic progress based on task states.

## Usage
```
/pm:epic-refresh <project_name> <feature_name> <epic_name>
```

## Required Rules

**IMPORTANT:** Before executing this command, read and follow:
- `.claude/rules/datetime.md` - For getting real current date/time

## Preflight Checklist

Before proceeding, complete these validation steps.

1. **Verify parameters:**
   - Check if all three `<project_name>`, `<feature_name>`, `<epic_name>` were provided
   - If not, tell user: " Parameters missing. Please run: /pm:epic-refresh <project_name> <feature_name> <epic_name>"
   - Stop execution if parameters are missing

2. **Verify epic exists:**
   - Check if `./doc/$project_name/epics/$feature_name/$epic_name.md` exists
   - If not found, tell user: " Epic not found: ./doc/$project_name/epics/$feature_name/$epic_name.md"
   - Stop execution if epic doesn't exist

## Instructions

### 1. Count Task Status

Scan all task files in `./doc/$project_name/epics/$feature_name/$epic_name/`:
- Count total tasks
- Count tasks with `status: closed`
- Count tasks with `status: open`
- Count tasks with work in progress

### 2. Calculate Progress

```
progress = (closed_tasks / total_tasks) * 100
```

Round to nearest integer.

### 3. Update GitHub Task List

If epic has GitHub issue, sync task checkboxes:

```bash
epic_file="./doc/$project_name/epics/$feature_name/$epic_name.md"

# Get epic issue number from epic.md frontmatter
github_url=$(grep "^github:" "$epic_file" | sed 's/^github: *//')
epic_issue=$(echo "$github_url" | grep -o '/[0-9]*$' | tr -d '/')

if [ -n "$epic_issue" ]; then
  # Get repo
  remote_url=$(git remote get-url origin 2>/dev/null || echo "")
  REPO=$(echo "$remote_url" | sed 's|.*github.com[:/]||' | sed 's|\.git$||')
  
  # Get current epic body
  gh issue view "$epic_issue" --repo "$REPO" --json body -q .body > /tmp/epic-body.md
  
  # For each task, check its status and update checkbox
  epic_dir="./doc/$project_name/epics/$feature_name/$epic_name"
  for task_file in "$epic_dir"/[0-9]*.md; do
    [ -f "$task_file" ] || continue
    
    # Extract task issue number
    task_issue=$(basename "$task_file" .md)
    task_status=$(grep '^status:' "$task_file" | head -1 | sed 's/^status: *//')
    
    if [ "$task_status" = "closed" ]; then
      # Mark as checked
      sed -i "s/- \[ \] #$task_issue/- [x] #$task_issue/" /tmp/epic-body.md
    else
      # Ensure unchecked
      sed -i "s/- \[x\] #$task_issue/- [ ] #$task_issue/" /tmp/epic-body.md
    fi
  done
  
  # Update epic issue
  gh issue edit "$epic_issue" --repo "$REPO" --body-file /tmp/epic-body.md
fi
```

### 4. Determine Epic Status

- If progress = 0% and no work started: `backlog`
- If progress > 0% and < 100%: `in-progress`
- If progress = 100%: `completed`

### 5. Update Epic

Get current datetime: `date -u +"%Y-%m-%dT%H:%M:%SZ"`

Update `./doc/$project_name/epics/$feature_name/$epic_name.md` frontmatter:
```yaml
status: {calculated_status}
progress: {calculated_progress}%
updated: {current_datetime}
```

### 6. Output

```
 Epic Refreshed: $epic_name
   Project: $project_name
   Feature: $feature_name

 Tasks:
  Closed: {closed_count}
  Open: {open_count}
  Total: {total_count}
  
 Progress: {old_progress}% → {new_progress}%
 Status: {old_status} → {new_status}
{If has GitHub}:  GitHub task list updated

{If complete}: Run /pm:epic-close $project_name $feature_name $epic_name to close epic
{If in progress}: Run /pm:next to see priority tasks
```

## Error Handling

If any step fails:
- Report which calculation succeeded/failed
- Show current state even if update fails
- Allow user to manually check tasks if needed

## Important Notes

- Use this after manual task edits
- Use this after GitHub sync to keep in sync
- Don't modify task files directly, let this update epic status
- Preserve all other frontmatter fields
- Update timestamp on every refresh