---
allowed-tools: Bash, Read, Write, LS
---

# Epic Start

Prepare environment and identify ready tasks for epic development.

## Usage
```
/pm:epic-start <project_name> <feature_name> <epic_name>
```

## Description

This command prepares the environment for epic development by:
1. Creating the epic branch
2. Creating a worktree for isolated development
3. Analyzing task dependencies
4. Identifying the first ready task
5. Updating execution status with next_task
6. Verifying the environment is ready

**Does NOT launch any agents** (that's `/pm:issue-start`)

## Required Rules

**IMPORTANT:** Before executing this command, read and follow:
- `/rules/branch-operations.md` - For git branch operations

## Quick Check

1. **Verify parameters:**
   - Check if all three `<project_name>`, `<feature_name>`, `<epic_name>` were provided
   - If not, tell user: " Parameters missing. Please run: /pm:epic-start <project_name> <feature_name> <epic_name>"

2. **Verify epic exists:**
   ```bash
   test -f ./doc/$project_name/epics/$feature_name/$epic_name.md || echo " Epic not found. Run: /pm:prd-parse $project_name $feature_name"
   ```

3. **Check GitHub sync:**
   Look for `github:` field in epic frontmatter at `./doc/$project_name/epics/$feature_name/$epic_name.md`
   If missing: " Epic not synced. Run: /pm:epic-sync $project_name $feature_name $epic_name first"

4. **Check for branch:**
   ```bash
   git branch -a | grep "epic/$epic_name"
   ```

5. **Check for uncommitted changes:**
   ```bash
   git status --porcelain
   ```
   If output is not empty: " You have uncommitted changes. Please commit or stash them before starting an epic"

6. **Verify tasks exist:**
   Check if `./doc/$project_name/epics/$feature_name/$epic_name/` directory has task files.
   If empty: " No tasks found. Run: /pm:epic-decompose $project_name $feature_name $epic_name first"

## Instructions

### 1. Create or Enter Branch

Follow `/rules/branch-operations.md`:

```bash
# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
  echo " You have uncommitted changes. Please commit or stash them before starting an epic."
  exit 1
fi

# If branch doesn't exist, create it
if ! git branch -a | grep -q "epic/$epic_name"; then
  git checkout main
  git pull origin main
  git checkout -b epic/$epic_name
  git push -u origin epic/$epic_name
  echo "✓ Created branch: epic/$epic_name"
else
  git checkout epic/$epic_name
  git pull origin epic/$epic_name
  echo "✓ Using existing branch: epic/$epic_name"
fi
```

### 2. Create Worktree

Create a dedicated worktree for this epic's development:

```bash
worktree_dir="../epic-$feature_name"

# Check if worktree already exists
if [ -d "$worktree_dir" ]; then
  echo " Worktree already exists: $worktree_dir"
  echo " Cleaning up and recreating..."
  
  # Try to remove existing worktree
  git worktree remove "$worktree_dir" --force 2>/dev/null || true
  
  # If directory still exists, remove it manually
  if [ -d "$worktree_dir" ]; then
    rm -rf "$worktree_dir"
  fi
fi

echo " Creating worktree: $worktree_dir"
git worktree add "$worktree_dir" epic/$epic_name || {
  echo "❌ Failed to create worktree"
  exit 1
}

echo "✓ Worktree created: $worktree_dir"
```

### 3. Identify Ready Tasks

Read all task files and build dependency graph:

```bash
# Create arrays for task categorization
ready_tasks=()
blocked_tasks=()
total_tasks=0
first_ready_task=""

for task_file in ./doc/$project_name/epics/$feature_name/$epic_name/[0-9]*.md; do
  [ -f "$task_file" ] || continue
  
  total_tasks=$((total_tasks + 1))
  
  # Parse task info
  task_num=$(basename "$task_file" .md)
  task_name=$(grep '^name:' "$task_file" | sed 's/^name: *//')
  depends_on=$(grep '^depends_on:' "$task_file" | sed 's/^depends_on: *//')
  status=$(grep '^status:' "$task_file" | sed 's/^status: *//')
  
  # Skip completed tasks
  if [ "$status" = "completed" ]; then
    continue
  fi
  
  # Categorize: ready if no dependencies
  if [ -z "$depends_on" ] || [ "$depends_on" = "[]" ]; then
    ready_tasks+=("$task_num")
    # Store first ready task for next_task field
    if [ -z "$first_ready_task" ]; then
      first_ready_task="$task_num"
    fi
  else
    blocked_tasks+=("$task_num")
  fi
done

echo "✓ Total tasks: $total_tasks"
echo "✓ Ready to start: ${#ready_tasks[@]}"
echo "✓ Blocked (waiting): ${#blocked_tasks[@]}"
```

### 4. Update Execution Status

Update `./doc/$project_name/epics/$feature_name/$epic_name/execution-status.md` with worktree absolute path and next_task:

```bash
current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Calculate and save absolute worktree path
# Get absolute path to main directory
main_dir_absolute=$(cd "$(pwd)" && pwd)

# Worktree is in parent directory: ../epic-$feature_name
worktree_dir="../epic-$feature_name"
worktree_absolute=$(cd "$worktree_dir" 2>/dev/null && pwd || echo "")

if [ -z "$worktree_absolute" ]; then
  echo "❌ Cannot determine absolute path for worktree"
  exit 1
fi

echo "✓ Worktree absolute path: $worktree_absolute"

# Build task status section
task_status_section=""
for task_file in ./doc/$project_name/epics/$feature_name/$epic_name/[0-9]*.md; do
  [ -f "$task_file" ] || continue
  
  task_num=$(basename "$task_file" .md)
  task_name=$(grep '^name:' "$task_file" | sed 's/^name: *//')
  status=$(grep '^status:' "$task_file" | sed 's/^status: *//')
  depends_on=$(grep '^depends_on:' "$task_file" | sed 's/^depends_on: *//')
  
  # Determine status icon
  if [ "$status" = "completed" ]; then
    status_icon="✅"
  elif [ -z "$depends_on" ] || [ "$depends_on" = "[]" ]; then
    status_icon="🟢"
  else
    status_icon="🔴"
  fi
  
  task_status_section="$task_status_section
### Task #$task_num: $task_name
- Status: $status $status_icon
- Depends on: $depends_on"
done

# Build ready tasks list
ready_list=""
for task_num in "${ready_tasks[@]}"; do
  task_file="./doc/$project_name/epics/$feature_name/$epic_name/$task_num.md"
  task_name=$(grep '^name:' "$task_file" | sed 's/^name: *//')
  ready_list="$ready_list
- **Task #$task_num**: $task_name"
done

# Update execution-status.md with ABSOLUTE WORKTREE PATH and NEXT_TASK
cat > ./doc/$project_name/epics/$feature_name/$epic_name/execution-status.md << EOF
---
epic: $epic_name
status: in_progress
started: $current_date
last_sync: $current_date
completion: 0%
total_tasks: $total_tasks
branch: epic/$epic_name
worktree_relative: ../epic-$feature_name
worktree_absolute: $worktree_absolute
project: $project_name
feature: $feature_name
next_task: $first_ready_task
---

# Execution Status

## Environment Information
- **Epic**: $epic_name
- **Branch**: epic/$epic_name
- **Worktree**: $worktree_absolute
- **Project**: $project_name
- **Feature**: $feature_name

## Progress Summary
- Total tasks: $total_tasks
- Completed: 0
- In progress: 0
- Ready: ${#ready_tasks[@]}
- Blocked: ${#blocked_tasks[@]}

## Ready to Start Now
$ready_list

## Task Status
$task_status_section

## Usage for Next Steps

### Manual execution:
\`\`\`bash
/pm:issue-start 2
\`\`\`

### For issue-start to use:
- Use worktree_absolute path from frontmatter
- cd \$worktree_absolute before executing agents

## Notes
Environment prepared for epic execution.
Worktree path is absolute and can be used from any directory.
Next step: Run /pm:issue-start to execute first ready task.