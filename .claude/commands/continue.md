---
name: continue
description: "Resume project development in a new session. AUTOMATICALLY detects the active project from dev/active/, loads all three project documents (plan/context/tasks), understands current progress, and continues implementation from the next uncompleted task."
---

# Continue Command - Seamless Session Resumption

Resume development exactly where you left off, automatically loading all project context.

## How It Works

### Step 1: Auto-Detect Active Project
```bash
# Check if dev/active/ exists
if [ ! -d "dev/active/" ]; then
    echo "No active projects found"
    echo "Run /dev-docs first to create a new project"
    exit 1
fi

# Get most recently modified project
PROJECT_NAME=$(ls -t dev/active/ | head -1)
PROJECT_PATH="dev/active/$PROJECT_NAME"
```

### Step 2: Verify Project Files Exist
```bash
# Check for all three required files
if [ ! -f "$PROJECT_PATH/$PROJECT_NAME-plan.md" ]; then
    echo "Missing: $PROJECT_NAME-plan.md"
    exit 1
fi

if [ ! -f "$PROJECT_PATH/$PROJECT_NAME-context.md" ]; then
    echo "Missing: $PROJECT_NAME-context.md"
    exit 1
fi

if [ ! -f "$PROJECT_PATH/$PROJECT_NAME-tasks.md" ]; then
    echo "Missing: $PROJECT_NAME-tasks.md"
    exit 1
fi
```

### Step 3: CRITICAL - Verify Working Directory at Project Root
```bash
# Verify we are at project root
if [ ! -d "dev/active/$PROJECT_NAME" ]; then
    echo "ERROR: Not at project root!"
    exit 1
fi

CURRENT_DIR=$(pwd)
echo "Working directory: $CURRENT_DIR"
echo "Code location: ./src/, ./tests/, ./config/"
echo "Docs location: dev/active/$PROJECT_NAME/"
```

### Step 4: Auto-Load Project Documents (Do NOT change directory)
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
- Dependencies between tasks

### Step 5: Analyze Current Progress

Based on tasks.md, Claude determines:
- How many tasks are completed
- How many tasks are in progress
- How many tasks are not started
- Overall completion percentage
- Next uncompleted task to work on

### Step 6: Continue Implementation at Project Root

Claude will:

1. **Review next uncompleted task details**
   - Read specific task description
   - Check dependencies
   - Understand acceptance criteria

2. **Load relevant context**
   - Check architecture decisions
   - Review current system state
   - Identify any blockers

3. **Start implementation**
   - Create files in: `./src/`, `./tests/`, `./config/`
   - NOT in: `dev/active/[project]/`
   - Follow RoyalTek code standards
   - Apply code-style skill

4. **Update progress after completion**
   - Mark task as "Completed" in: `dev/active/$PROJECT_NAME/$PROJECT_NAME-tasks.md`
   - Update progress percentage
   - Add implementation notes
   - Move to next task

## Command Flow

```
User: continue
  ↓
Auto-detect dev/active/ directory
  ↓
Find most recently modified project
  ↓
Load [project-name]-plan.md
Load [project-name]-context.md
Load [project-name]-tasks.md
  ↓
Verify at project root (CRITICAL)
  ↓
Analyze completion status
  ↓
Continue implementation from project root
  ↓
Auto-update tasks.md as tasks complete
```

## Working Directory Strategy

**CRITICAL**: Work from project root throughout entire session

```
✓ Code location: ./src/, ./tests/, ./config/
✓ Docs location: dev/active/[project-name]/
✓ Working directory: Project root (never change)

✗ DO NOT write code to: dev/active/[project-name]/src/
✗ DO NOT change to: dev/active/[project-name]/
```

## Error Handling

### Missing dev/active/ directory
```
Error: dev/active/ directory not found
Run /dev-docs first to create a new project
```

### Missing project files
```
Error: Cannot find project files
Solution: Run /update-dev-docs to regenerate files
```

### Not at project root
```
ERROR: Not at project root!
Make sure you're in the project directory
```

### No uncompleted tasks
```
✓ All tasks completed!
Project: royaltek-dashboard
Status: 100% Complete
```

## Switching Between Projects

If you have multiple projects in dev/active/:

```
User: continue web-ui-dashboard
  ↓
Auto-loads dev/active/web-ui-dashboard/
  ↓
Continues from project root
```

## Task Status Updates

After completing each task, tasks.md is updated at: `dev/active/$PROJECT_NAME/$PROJECT_NAME-tasks.md`

```markdown
### Task 1.4: Database Schema Design
- [x] **Status**: Completed
- **Completion Time**: 45 minutes
- **Notes**: Implementation details
```

## Important Notes

- **Automatic context loading** - No manual file loading needed
- **Working directory verified** - Always at project root
- **Seamless resumption** - Picks up exactly where you left off
- **Progress persistence** - All work saved in markdown files
- **Code in project root** - `./src/`, `./tests/`, `./config/`
- **Docs in dev/active/** - Planning documentation only

## Next Steps

After completing tasks:

- `/update-dev-docs` - Save progress when context is full
- `/dev-docs` - Create new project
- `continue` - Resume development

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Code in wrong location | Ensure you're at project root before running continue |
| "dev/active/ not found" | Run `/dev-docs` first |
| "Missing task file" | Run `/update-dev-docs` to save files |
| Wrong project loading | Use explicit name: `continue project-name` |

## See Also

- `/dev-docs` - Create new development documentation
- `/update-dev-docs` - Save progress and clear context
- `Execute plan` - Start implementation based on plan.md
