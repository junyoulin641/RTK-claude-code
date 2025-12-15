---
allowed-tools: Bash, Read, Write, LS, Task
---

# Epic Start

Launch parallel agents to work on epic tasks in a shared worktree.

## Usage
```
/pm:epic-start <project_name> <feature_name> <epic_name>
```

## Required Rules

**IMPORTANT:** Before executing this command, read and follow:
- `/rules/branch-operations.md` - For git branch operations
- `/rules/agent-coordination.md` - For parallel agent coordination

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
  echo " Created branch: epic/$epic_name"
else
  git checkout epic/$epic_name
  git pull origin epic/$epic_name
  echo " Using existing branch: epic/$epic_name"
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
git worktree add "$worktree_dir" -b epic/$epic_name || {
  echo "❌ Failed to create worktree"
  exit 1
}

echo "✓ Worktree created: $worktree_dir"
```

### 3. Enter Worktree

Navigate into the worktree to perform all development work:

```bash
worktree_dir="../epic-$feature_name"

echo " Entering worktree: $worktree_dir"
cd "$worktree_dir" || {
  echo "❌ Cannot access worktree: $worktree_dir"
  exit 1
}

echo "✓ Current location: $(pwd)"
echo "✓ Current branch: $(git branch --show-current)"

# Verify we're on the correct branch
current_branch=$(git branch --show-current)
if [ "$current_branch" != "epic/$epic_name" ]; then
  echo "❌ Expected branch epic/$epic_name, but on $current_branch"
  exit 1
fi
```

### 4. Identify Ready Issues

Read all task files in `./doc/$project_name/epics/$feature_name/$epic_name/`:
- Parse frontmatter for `status`, `depends_on`, `parallel` fields
- Check GitHub issue status if needed
- Build dependency graph

Categorize issues:
- **Ready**: No unmet dependencies, not started
- **Blocked**: Has unmet dependencies
- **In Progress**: Already being worked on
- **Complete**: Finished

```bash
ready_issues=()
blocked_issues=()

for task_file in ./doc/$project_name/epics/$feature_name/$epic_name/[0-9]*.md; do
  [ -f "$task_file" ] || continue
  
  # Parse task info
  task_num=$(basename "$task_file" .md)
  task_name=$(grep '^name:' "$task_file" | sed 's/^name: *//')
  depends_on=$(grep '^depends_on:' "$task_file" | sed 's/^depends_on: *//')
  
  # Check if dependencies are met
  if [ -z "$depends_on" ] || [ "$depends_on" = "[]" ]; then
    ready_issues+=("$task_num")
  else
    blocked_issues+=("$task_num")
  fi
done
```

### 5. Analyze Ready Issues

For each ready issue without analysis:
```bash
# Check for analysis
if ! test -f ./doc/$project_name/epics/$feature_name/$epic_name/{issue}-analysis.md; then
  echo "Analyzing issue #{issue}..."
  # Run analysis (inline or via Task tool)
fi
```

### 6. Launch Parallel Agents

For each ready issue with analysis:

```markdown
## Starting Issue #{issue}: {title}

Reading analysis...
Found {count} parallel streams:
  - Stream A: {description} (Agent-{id})
  - Stream B: {description} (Agent-{id})

Launching agents in worktree: $(pwd)
Branch: epic/$epic_name
```

Use Task tool to launch each stream:
```yaml
Task:
  description: "Issue #{issue} Stream {X}"
  subagent_type: "{agent_type}"
  prompt: |
    You are working in the epic worktree for development.
    
    Worktree Location: ../epic-{feature_name}/ (YOU ARE ALREADY HERE)
    Branch: epic/$epic_name
    Project: $project_name
    Feature: $feature_name
    Epic: $epic_name
    Issue: #{issue} - {title}
    Stream: {stream_name}

    Current directory: $(pwd)

    Your scope:
    - Files: {file_patterns}
    - Work: {stream_description}

    IMPORTANT: You are already in the worktree directory.
    All file paths are relative to this location.

    Read full requirements from:
    - ./doc/$project_name/epics/$feature_name/$epic_name/{task_file}
    - ./doc/$project_name/epics/$feature_name/$epic_name/{issue}-analysis.md

    Follow coordination rules in /rules/agent-coordination.md

    Commit frequently with message format:
    "Issue #{issue}: {specific change}"

    Update progress in:
    ./doc/$project_name/epics/$feature_name/$epic_name/updates/{issue}/stream-{X}.md

    When complete, do NOT exit the worktree.
    Other agents may still be working in this directory.
```

### 7. Track Active Agents

Create/update `./doc/$project_name/epics/$feature_name/$epic_name/execution-status.md`:

```markdown
---
started: {datetime}
branch: epic/$epic_name
project: $project_name
feature: $feature_name
epic: $epic_name
worktree: ../epic-$feature_name
---

# Execution Status

## Active Agents
- Agent-1: Issue #1234 Stream A (Database) - Started {time}
- Agent-2: Issue #1234 Stream B (API) - Started {time}
- Agent-3: Issue #1235 Stream A (UI) - Started {time}

## Queued Issues
- Issue #1236 - Waiting for #1234
- Issue #1237 - Waiting for #1235

## Completed
- {None yet}
```

### 8. Monitor and Coordinate

Set up monitoring:
```bash
echo "
Agents launched successfully in worktree!

Current location: $(pwd)
Current branch: $(git branch --show-current)

Monitor progress:
  /pm:epic-status $project_name $feature_name $epic_name

View branch changes:
  git status

Stop all agents:
  /pm:epic-stop $project_name $feature_name $epic_name

Merge when complete:
  /pm:epic-merge $project_name $feature_name $epic_name

To return to main directory:
  cd ../pt
"
```

### 9. Handle Dependencies

As agents complete streams:
- Check if any blocked issues are now ready
- Launch new agents for newly-ready work
- Update execution-status.md

When a task is marked as complete:
```bash
# Check if dependent tasks are now ready
# For each blocked task:
#   if [ task's dependencies all complete ]; then
#     /pm:issue-start <issue_number>
#   fi
```

## Output Format

```
✓ Epic Execution Started: $epic_name
  Project: $project_name
  Feature: $feature_name

Worktree: ../epic-$feature_name
Branch: epic/$epic_name
Current location: /path/to/epic-$feature_name

Launching {total} agents across {issue_count} issues:

Issue #2: Setup Project Structure
  ├─ Stream A: Directory structure (Agent-1) ✓ Started
  └─ Stream B: Config files (Agent-2) ✓ Started

Issue #3: Implement Core Window
  ├─ Stream A: Window class (Agent-3) ✓ Started
  ├─ Stream B: Event handlers (Agent-4) ✓ Started
  └─ Stream C: Tests (Agent-5) ⏸ Waiting for A & B

Blocked Issues (2):
  - #4: Add UI Components (depends on #3)
  - #5: Integration (depends on #4)

Ready for next task:
  When Issue #2 completes, Issue #3 will become ready.
  Use: /pm:issue-start 3

Monitor with: /pm:epic-status $project_name $feature_name $epic_name
```

## Error Handling

If worktree creation fails:
```
❌ Failed to create worktree

Possible causes:
  - Directory ../epic-$feature_name already exists
  - Branch epic/$epic_name doesn't exist on remote
  - Permission issues

Solution:
  1. Check existing worktrees: git worktree list
  2. Remove conflicting directory: rm -rf ../epic-$feature_name
  3. Retry: /pm:epic-start $project_name $feature_name $epic_name
```

If agent launch fails:
```
❌ Failed to start Agent-{id}
  Issue: #{issue}
  Stream: {stream}
  Error: {reason}

Continue with other agents? (yes/no)
```

If uncommitted changes are found:
```
⚠️ You have uncommitted changes. Please commit or stash them before starting an epic.

To commit changes:
  git add .
  git commit -m "Your commit message"

To stash changes:
  git stash push -m "Work in progress"
  # (Later restore with: git stash pop)
```

If branch creation fails:
```
❌ Cannot create branch
  {git error message}

Try: git branch -d epic/$epic_name
Or: Check existing branches with: git branch -a
```

## Important Notes

- **Follow `/rules/branch-operations.md` for git operations**
- **Follow `/rules/agent-coordination.md` for parallel work**
- **You MUST be in the worktree directory when launching agents**
- **All agents work in the SAME worktree and SAME branch**
- **All file paths in agent prompts are relative to worktree root**
- Maximum parallel agents should be reasonable (e.g., 5-10)
- Monitor system resources if launching many agents
- Update execution-status.md as agents complete streams
- Do NOT leave the worktree during development (other agents may be there)
- Return to main directory only when epic is complete: `/pm:epic-merge`