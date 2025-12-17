---
allowed-tools: Bash, Read, Write, LS
---

# Epic Refresh

Update epic progress based on task states. Recalculate which tasks are ready and update next_task for automation.

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
   - If not, tell user: "Parameters missing. Please run: /pm:epic-refresh <project_name> <feature_name> <epic_name>"
   - Stop execution if parameters are missing

2. **Verify epic exists:**
   - Check if `./doc/$project_name/epics/$feature_name/$epic_name.md` exists
   - If not found, tell user: "Epic not found: ./doc/$project_name/epics/$feature_name/$epic_name.md"
   - Stop execution if epic doesn't exist

3. **Verify execution-status.md exists:**
   - Check if `./doc/$project_name/epics/$feature_name/$epic_name/execution-status.md` exists
   - If not, suggest running: `/pm:epic-start $project_name $feature_name $epic_name`

## Instructions

### 1. Count Task Status

Scan all task files in `./doc/$project_name/epics/$feature_name/$epic_name/`:

```bash
epic_dir="./doc/$project_name/epics/$feature_name/$epic_name"
total_tasks=0
closed_tasks=0
open_tasks=0
in_progress_tasks=0

for task_file in "$epic_dir"/[0-9]*.md; do
  [ -f "$task_file" ] || continue
  
  total_tasks=$((total_tasks + 1))
  
  status=$(grep '^status:' "$task_file" | head -1 | sed 's/^status: *//')
  
  case "$status" in
    closed|completed)
      closed_tasks=$((closed_tasks + 1))
      ;;
    in-progress|active)
      in_progress_tasks=$((in_progress_tasks + 1))
      ;;
    open|*)
      open_tasks=$((open_tasks + 1))
      ;;
  esac
done

echo "Task Count:"
echo "  Total: $total_tasks"
echo "  Closed: $closed_tasks"
echo "  In Progress: $in_progress_tasks"
echo "  Open: $open_tasks"
```

### 2. Identify Ready Tasks

Recalculate which tasks are ready (no unmet dependencies):

```bash
ready_tasks=()
blocked_tasks=()
newly_ready_tasks=()

for task_file in "$epic_dir"/[0-9]*.md; do
  [ -f "$task_file" ] || continue
  
  task_num=$(basename "$task_file" .md)
  depends_on=$(grep '^depends_on:' "$task_file" | sed 's/^depends_on: *//')
  status=$(grep '^status:' "$task_file" | sed 's/^status: *//')
  
  # Skip completed tasks
  if [ "$status" = "completed" ] || [ "$status" = "closed" ]; then
    continue
  fi
  
  # Check if dependencies are met
  if [ -z "$depends_on" ] || [ "$depends_on" = "[]" ]; then
    ready_tasks+=("$task_num")
  else
    # Check if this task just became ready
    deps=$(echo "$depends_on" | sed 's/^\[//' | sed 's/\]//' | sed 's/,/ /g' | sed 's/[[:space:]]//g')
    
    all_deps_complete=true
    for dep in $deps; do
      dep_file="$epic_dir/$dep.md"
      if [ -f "$dep_file" ]; then
        dep_status=$(grep '^status:' "$dep_file" | sed 's/^status: *//')
        if [ "$dep_status" != "completed" ] && [ "$dep_status" != "closed" ]; then
          all_deps_complete=false
          break
        fi
      fi
    done
    
    if [ "$all_deps_complete" = true ]; then
      ready_tasks+=("$task_num")
      newly_ready_tasks+=("$task_num")
    else
      blocked_tasks+=("$task_num")
    fi
  fi
done

echo "Ready Tasks: ${#ready_tasks[@]}"
echo "Newly Ready: ${#newly_ready_tasks[@]}"
echo "Blocked: ${#blocked_tasks[@]}"
```

### 3. Calculate Progress

```bash
if [ "$total_tasks" -gt 0 ]; then
  old_progress=$(grep '^progress:' "./doc/$project_name/epics/$feature_name/$epic_name.md" | sed 's/^progress: *//' | sed 's/%//')
  new_progress=$((closed_tasks * 100 / total_tasks))
  
  echo "Progress: ${old_progress}% → ${new_progress}%"
else
  old_progress=0
  new_progress=0
fi
```

### 4. Determine Epic Status

```bash
epic_file="./doc/$project_name/epics/$feature_name/$epic_name.md"
old_status=$(grep '^status:' "$epic_file" | sed 's/^status: *//')

if [ "$new_progress" -eq 0 ] && [ "$in_progress_tasks" -eq 0 ]; then
  new_status="backlog"
elif [ "$new_progress" -eq 100 ]; then
  new_status="completed"
else
  new_status="in-progress"
fi

echo "Status: $old_status → $new_status"
```

### 5. Determine Next Task

```bash
next_task=""
if [ ${#ready_tasks[@]} -gt 0 ]; then
  # Get first ready task
  next_task="${ready_tasks[0]}"
  
  # Skip if already in progress
  task_file="$epic_dir/$next_task.md"
  if [ -f "$task_file" ]; then
    status=$(grep '^status:' "$task_file" | sed 's/^status: *//')
    if [ "$status" = "in-progress" ] || [ "$status" = "active" ]; then
      # Find first open ready task
      for t in "${ready_tasks[@]}"; do
        tf="$epic_dir/$t.md"
        [ -f "$tf" ] || continue
        ts=$(grep '^status:' "$tf" | sed 's/^status: *//')
        if [ "$ts" != "in-progress" ] && [ "$ts" != "active" ]; then
          next_task="$t"
          break
        fi
      done
    fi
  fi
fi

echo "Next Task: $next_task"
```

### 6. Update GitHub Task List (if applicable)

```bash
github_url=$(grep "^github:" "$epic_file" | sed 's/^github: *//')

if [ -n "$github_url" ]; then
  epic_issue=$(echo "$github_url" | grep -o '/[0-9]*$' | tr -d '/')
  
  if [ -n "$epic_issue" ]; then
    remote_url=$(git remote get-url origin 2>/dev/null || echo "")
    REPO=$(echo "$remote_url" | sed 's|.*github.com[:/]||' | sed 's|\.git$||')
    
    if [ -n "$REPO" ]; then
      echo "Updating GitHub issue #$epic_issue..."
      
      # Get current epic body
      gh issue view "$epic_issue" --repo "$REPO" --json body -q .body > /tmp/epic-body.md 2>/dev/null
      
      if [ -f /tmp/epic-body.md ]; then
        # Update task checkboxes based on current status
        for task_file in "$epic_dir"/[0-9]*.md; do
          [ -f "$task_file" ] || continue
          
          task_issue=$(basename "$task_file" .md)
          task_status=$(grep '^status:' "$task_file" | sed 's/^status: *//')
          
          if [ "$task_status" = "closed" ] || [ "$task_status" = "completed" ]; then
            sed -i "s/- \[ \] #$task_issue/- [x] #$task_issue/" /tmp/epic-body.md 2>/dev/null
          else
            sed -i "s/- \[x\] #$task_issue/- [ ] #$task_issue/" /tmp/epic-body.md 2>/dev/null
          fi
        done
        
        # Update epic issue
        gh issue edit "$epic_issue" --repo "$REPO" --body-file /tmp/epic-body.md 2>/dev/null && \
          echo "GitHub issue updated"
      fi
    fi
  fi
fi
```

### 7. Update Epic File

Get current datetime and update frontmatter:

```bash
current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Read entire file
content=$(cat "$epic_file")

# Update frontmatter fields
content=$(echo "$content" | sed "/^status:/c\status: $new_status")
content=$(echo "$content" | sed "/^progress:/c\progress: $new_progress%")
content=$(echo "$content" | sed "/^updated:/c\updated: $current_date")

# Write back
echo "$content" > "$epic_file"

echo "Epic file updated"
```

### 8. Update Execution Status File

Update `execution-status.md` with new task counts and next_task:

```bash
status_file="$epic_dir/execution-status.md"

if [ -f "$status_file" ]; then
  current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  # Update frontmatter
  content=$(cat "$status_file")
  
  content=$(echo "$content" | sed "/^last_sync:/c\last_sync: $current_date")
  content=$(echo "$content" | sed "/^completion:/c\completion: $new_progress%")
  content=$(echo "$content" | sed "/^next_task:/c\next_task: $next_task")
  
  echo "$content" > "$status_file"
  
  echo "Execution status updated"
fi
```

## Output Format

```
✅ Epic Refreshed: $epic_name

📊 Task Summary:
  Project: $project_name
  Feature: $feature_name

📈 Progress Update:
  Total tasks: $total_tasks
  Completed: $closed_tasks
  In Progress: $in_progress_tasks
  Open: $open_tasks
  
  Progress: ${old_progress}% → ${new_progress}%
  Status: $old_status → $new_status

🔍 Ready Analysis:
  Ready tasks: ${#ready_tasks[@]}
  Newly ready: ${#newly_ready_tasks[@]}
  Blocked: ${#blocked_tasks[@]}

🎯 Next Command:
  /pm:issue-start $next_task

{If newly ready tasks}:
  ✅ Newly ready tasks:
     {list newly_ready_tasks}

{If complete}:
  ✅ All tasks completed!
  Next: /pm:epic-close $project_name $feature_name $epic_name

{If GitHub synced}:
  ✅ GitHub task list updated

📁 Files updated:
  - ./doc/$project_name/epics/$feature_name/$epic_name.md
  - ./doc/$project_name/epics/$feature_name/$epic_name/execution-status.md
```

## Error Handling

If any step fails:
- Report which calculation succeeded/failed
- Show current state even if update fails
- Allow user to manually check tasks if needed
- Don't partially update files

Example error handling:
```bash
if ! grep -q "^progress:" "$epic_file"; then
  echo "⚠️ Warning: Could not update progress in epic file"
  echo "Manual update needed for: $epic_file"
fi
```

## Important Notes

- Run this after task completion to recalculate ready tasks
- Run this after manual task edits to sync state
- Run this after GitHub sync to refresh next_task
- Preserves all other frontmatter fields
- Updates timestamp on every refresh
- Identifies newly ready tasks for notifications
- Updates next_task for epic-auto automation

## Key Features

### 1. Detects Newly Ready Tasks
When a task completes, epic-refresh identifies which blocked tasks can now start:
```
🔍 Ready Analysis:
  Ready tasks: 3
  Newly ready: 2  ← These tasks just became available!
  Blocked: 4
```

### 2. Updates next_task Field
For automation to work, next_task must be kept current:
```yaml
---
next_task: 3
---
```

### 3. Supports Cascading Automation
When epic-auto calls epic-refresh, it can continue:
```bash
# epic-auto flow:
/pm:issue-start 2  # Complete task
/pm:issue-sync 2   # Sync to GitHub (calls epic-refresh)
# epic-refresh updates next_task to 3
/pm:issue-start 3  # Continue automatically
```

## Integration with Other Commands

### Called by: issue-sync
After task completion, should trigger refresh:
```bash
/pm:issue-sync 2
# → internally calls epic-refresh
# → updates next_task
# → shows next command
```

### Used by: epic-auto
Reads next_task to continue execution:
```bash
next=$(grep '^next_task:' execution-status.md | sed 's/^next_task: *//')
/pm:issue-start "$next"
```

### Updates: execution-status.md
Keeps automation data current:
- `next_task: 3` - Next ready task
- `completion: 35%` - Current progress
- `last_sync` - When this was updated

## Workflow: How Refresh Enables Automation

```
Step 1: Task #2 completes
  /pm:issue-start 2
  → Agents finish work
  → Commit to branch

Step 2: Sync to GitHub
  /pm:issue-sync 2
  → Push changes
  → Update GitHub issue
  → Call epic-refresh (internal)

Step 3: epic-refresh runs
  ├─ Detects #2 is now closed
  ├─ Checks which tasks depended on #2
  ├─ Finds #3 and #4 are now ready
  ├─ Updates next_task: 3
  └─ Updates execution-status.md

Step 4: epic-auto continues
  ├─ Reads next_task: 3
  ├─ Runs /pm:issue-start 3
  ├─ When done, calls epic-refresh
  └─ Loop until no ready tasks

Result: Full automation chain!
  Task 1 → Task 2 → Task 3 → Task 4 → Done
  All driven by: epic-refresh + epic-auto
```

This enables hands-off automation while maintaining clarity about what's happening.