---
name: execute-plan
description: "Resume project development in a new session. AUTOMATICALLY detects the active project from dev/active/, loads all three project documents (plan/context/tasks), understands current progress, and continues implementation from the next uncompleted task."
---

# Execute Plan Command

Resume development exactly where you left off, automatically loading all project context.

## How It Works

### Step 1: Auto-Detect Active Project
```bash
if [ ! -d "dev/active/" ]; then
    echo "Run /dev-docs first"
    exit 1
fi

PROJECT_NAME=$(ls -t dev/active/ | head -1)
PROJECT_PATH="dev/active/$PROJECT_NAME"

echo "Detected project: $PROJECT_NAME"
```

### Step 2: Verify Project Files Exist
```bash
PLAN_FILE="$PROJECT_PATH/$PROJECT_NAME-plan.md"
CONTEXT_FILE="$PROJECT_PATH/$PROJECT_NAME-context.md"
TASKS_FILE="$PROJECT_PATH/$PROJECT_NAME-tasks.md"

if [ ! -f "$PLAN_FILE" ]; then
    echo "Plan not found. Run /dev-docs first"
    exit 1
fi
```

### Step 3: Auto-Load Project Documents
Claude automatically reads and understands:

**1. Project Plan** (`$PROJECT_NAME-plan.md`)
- Project overview and goals
- Implementation phases and tasks
- Risk assessment and timeline
- Success criteria

**2. Project Context** (`$PROJECT_NAME-context.md`)
- Project background and motivation
- Current architecture and tech stack
- Key file locations
- Architecture decisions and constraints

**3. Task Checklist** (`$PROJECT_NAME-tasks.md`)
- Complete list of all tasks by phase
- Completion status for each task
- Progress metrics

### Step 4: CRITICAL - Verify Working Directory
```bash
# Must verify we are STILL at project root
CURRENT_DIR=$(pwd)
PROJECT_ROOT=$(pwd)

if [ ! -d "dev/active/$PROJECT_NAME" ]; then
    echo "ERROR: Not at project root!"
    exit 1
fi

echo "Working directory: $CURRENT_DIR"
echo "Code will be written to: $PROJECT_ROOT/src/"
```

### Step 5: Begin Implementation
Now Claude can write code to the correct locations:
- Code written to: `./src/`
- Tests written to: `./tests/`
- Config written to: `./config/`
- Tasks updated to: `dev/active/$PROJECT_NAME/$PROJECT_NAME-tasks.md`

## Implementation Rules

### Rule 1: Maintain Project Root as Working Directory
```
DO:
  Working dir: /project-root/
  Write to: ./src/file.py = /project-root/src/file.py ✓

DON'T:
  Change to: dev/active/[project]/
  Write to: ./src/file.py = /project-root/dev/active/[project]/src/file.py ✗
```

### Rule 2: Reference Paths Correctly
```
CORRECT:
  cat dev/active/[project]/[project]-plan.md
  sed -i "..." dev/active/[project]/[project]-tasks.md

WRONG:
  cd dev/active/[project]/
  cat [project]-plan.md
```

### Rule 3: After Completing Each Task
- Update task status in: `dev/active/[project]/[project]-tasks.md`
- Continue to next task
- When context is full, execute `/update-dev-docs`

## Task Status Updates

After completing each task, tasks.md is updated:

```markdown
### Task 1.4: Database Schema Design
- [x] **Status**: Completed
- **Completion Time**: 45 minutes
```

Progress automatically updates.

## Important Notes

- **Automatic context loading** - No manual file loading needed
- **No configuration** - Works with any project structure
- **Seamless resumption** - Picks up exactly where you left off
- **Progress persistence** - All work saved in markdown files
