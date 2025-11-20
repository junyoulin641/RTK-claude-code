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
    echo " No active projects found"
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
    echo " Missing: $PROJECT_NAME-plan.md"
    exit 1
fi

if [ ! -f "$PROJECT_PATH/$PROJECT_NAME-context.md" ]; then
    echo " Missing: $PROJECT_NAME-context.md"
    exit 1
fi

if [ ! -f "$PROJECT_PATH/$PROJECT_NAME-tasks.md" ]; then
    echo " Missing: $PROJECT_NAME-tasks.md"
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
- Current blockers and status

**3. Task Checklist** (`$PROJECT_NAME-tasks.md`)
- Complete list of all tasks by phase
- Completion status for each task
- Progress metrics
- Dependencies between tasks
- Implementation notes

### Step 4: Analyze Current Progress

Based on tasks.md, Claude determines:
-  How many tasks are completed
-  How many tasks are in progress
-  How many tasks are not started
-  Overall completion percentage
-  Next uncompleted task to work on

### Step 5: Generate Status Summary
```
✓ Project detected: royaltek-dashboard
✓ Files loaded: plan, context, tasks
✓ Phase 1: 3/5 tasks completed (60%)
✓ Current task: 1.4 Database Schema Design
✓ Status: Ready to continue
```

### Step 6: Continue Implementation

Claude will:

1. **Review next uncompleted task details**
   - Read specific task description
   - Check dependencies (are dependencies completed?)
   - Understand acceptance criteria

2. **Load relevant context**
   - Check architecture decisions from context.md
   - Review current system state
   - Identify any blockers

3. **Start implementation**
   - Create necessary files/components
   - Follow RoyalTek code standards automatically
   - Apply code-style skill
   - Trigger code-reviewer when applicable

4. **Update progress after completion**
   - Mark task as "Completed" in tasks.md
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
Analyze completion status
  ↓
Display status summary
  ↓
Start/continue implementation from next uncompleted task
  ↓
Auto-update tasks.md as tasks complete
```

## Error Handling

### Missing dev/active/ directory
```
 Error: dev/active/ directory not found
Run /dev-docs first to create a new project

Example:
  /dev-docs
  Project name: my-project
  Description: My awesome project
```

### Missing project files
```
 Error: Cannot find [project-name]-plan.md
 Error: Cannot find [project-name]-context.md
 Error: Cannot find [project-name]-tasks.md

Solution: Run /update-dev-docs to regenerate files
```

### No uncompleted tasks
```
✓ All tasks completed!
Project: royaltek-dashboard
Status: 100% Complete

Options:
  1. Review completed tasks
  2. Add new tasks
  3. Start new project with /dev-docs
```

## Switching Between Projects

If you have multiple projects in dev/active/:

```
Current project: royaltek-dashboard (most recent)

To switch to specific project:
  User: continue web-ui-dashboard
    ↓
  Auto-loads dev/active/web-ui-dashboard/
  
Or just use most recent:
  User: continue
    ↓
  Auto-detects most recent: web-ui-dashboard
```

## Resume Behavior

### First Task of New Phase
```
Completing Phase 1, Task 5 ✓
Moving to Phase 2...
Resuming Phase 2, Task 1: API Development Setup
```

### Mid-Phase Resume
```
Resuming Phase 2
Last completed: Task 2.3 ✓
Next task: Task 2.4 - Error Handling Module
```

### Between Sessions (No Loss)
```
Session 1:
  Completed tasks 1.1, 1.2, 1.3
  Saved to tasks.md (60% progress)

Session 2 (continue command):
  Auto-loads tasks.md
  Sees tasks 1.1, 1.2, 1.3 are done
  Resumes from task 1.4
  Perfect continuity!
```

## Task Status Updates

After completing each task, tasks.md is updated:

```markdown
### Task 1.4: Database Schema Design
- [x] **Status**: Completed
- **Completion Time**: 45 minutes
- **Notes**: Implemented PostgreSQL schema with proper indexing
  - Created users table with authentication fields
  - Created products table with relationships
  - Added migration scripts
```

Progress automatically updates:

```markdown
## Progress Summary

### Phase 1
| Item | Count |
|------|-------|
| Total Tasks | 5 |
| Completed | 4 |
| In Progress | 1 |
| Not Started | 0 |
| **Progress** | **80%** |
```

## Important Notes

 **Automatic context loading** - No manual file loading needed  
 **No configuration** - Works with any project structure  
 **Seamless resumption** - Picks up exactly where you left off  
 **Progress persistence** - All work saved in markdown files  
 **Multiple projects** - Supports unlimited projects simultaneously  
 **Task dependencies** - Understands task relationships  

## Next Steps After Completion

### Current project complete?
```
/dev-docs
Create new project with updated system

Or continue with /update-dev-docs
```

### Context getting full (85%+)?
```
/update-dev-docs
Save all progress to files and clear context
```

### Switch to different project?
```
continue [project-name]
Or just: continue (uses most recent)
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "dev/active/ not found" | Run `/dev-docs` first to create project |
| "Missing task file" | Run `/update-dev-docs` to ensure files are saved |
| "Wrong project loading" | Use explicit project name: `continue project-name` |
| "Progress not updating" | Check file permissions in dev/active/ directory |

## See Also

- `/dev-docs` - Create new development documentation
- `/update-dev-docs` - Save progress and clear context
- `Execute plan` - Start implementation based on plan.md
