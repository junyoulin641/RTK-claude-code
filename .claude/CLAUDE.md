# Claude Project Development System

## Overview

This is a universal configuration that automatically supports ALL projects in `dev/active/` directory.

---

## Slash Commands

### /dev-docs
**Purpose**: Create comprehensive development documentation for a new project

**Usage**:
```
/dev-docs
```

**What it does**:
1. Asks for project name (e.g., royaltek-dashboard, web-ui-project)
2. Asks for project description
3. Analyzes current project structure
4. Enters Planning Mode (creates documents, doesn't write code)
5. Generates three documents in `dev/active/[project-name]/`:
   - `[project-name]-plan.md` - Complete project plan
   - `[project-name]-context.md` - Background and architecture
   - `[project-name]-tasks.md` - Task checklist

**Output**: Three markdown files ready for review

**Next**: Review documents, then say "Execute plan"

---

### Execute plan
**Purpose**: Start implementing based on the project plan

**Usage**:
```
Execute plan
```

**What Claude will do**:
1. Auto-detect current project in `dev/active/`
   - If multiple projects: Use most recently modified
   - If one project: Use that project
   
2. Auto-load all three project documents:
   ```bash
   cat dev/active/[project-name]/[project-name]-plan.md
   cat dev/active/[project-name]/[project-name]-context.md
   cat dev/active/[project-name]/[project-name]-tasks.md
   ```

3. Understand complete project structure and requirements

4. Begin implementation of Phase 1
   - Create project structure
   - Set up dependencies
   - Create base classes/components

5. Auto-format code using code-format skill

6. Update `tasks.md` after each completed task:
   - Mark task as "Completed"
   - Update progress percentage
   - Add implementation notes

**Important**: No manual file loading needed - Claude auto-detects and loads everything

---

### /update-dev-docs
**Purpose**: Save current progress when context is getting full

**Usage**:
```
/update-dev-docs
```

**When to use**: When context usage reaches 85%+

**What it does**:
1. Saves all current progress
2. Updates `[project-name]-tasks.md` with completed tasks
3. Documents current state
4. Clears context to continue working

**Result**: All work is preserved in markdown files, context is cleared

---

### continue
**Purpose**: Resume work on the current project in a new session

**Usage**:
```
continue
```

**What Claude will do**:
1. Auto-load project documents from `dev/active/[project-name]/`
2. Review current progress and completed tasks
3. Understand exactly where work was left off
4. Continue implementation from next uncompleted task
5. Update progress as work continues

**Result**: Seamless continuation without context loss

---

## Auto-Detection Logic

### When you say "Execute plan", Claude will:

```
Step 1: Check dev/active/ directory
  ✓ If exists: Continue
  ✗ If not exists: Ask you to run /dev-docs first

Step 2: List all projects in dev/active/
  • One project: Use that project
  • Multiple projects: Use most recently modified
  • No projects: Ask you to run /dev-docs first

Step 3: Auto-load three project documents
  cat dev/active/[project-name]/[project-name]-plan.md
  cat dev/active/[project-name]/[project-name]-context.md
  cat dev/active/[project-name]/[project-name]-tasks.md

Step 4: Understand the project completely

Step 5: Begin implementation according to plan
```

### Project Directory Structure

```
dev/active/
├── royaltek-dashboard/
│   ├── royaltek-dashboard-plan.md
│   ├── royaltek-dashboard-context.md
│   └── royaltek-dashboard-tasks.md
│
├── web-ui-project/
│   ├── web-ui-project-plan.md
│   ├── web-ui-project-context.md
│   └── web-ui-project-tasks.md
│
└── api-service/
    ├── api-service-plan.md
    ├── api-service-context.md
    └── api-service-tasks.md
```

---

## Development Workflow

### For Any New Project

```
Step 1: /dev-docs
        ↓ Provide project info
        ↓ Get three documents

Step 2: Review documents
        ↓ Check if plan is good
        ↓ Approve or request changes

Step 3: Execute plan
        ↓ Claude auto-loads documents
        ↓ Starts coding
        ↓ Auto-updates progress

Step 4: /update-dev-docs (when context is full)
        ↓ Save progress
        ↓ Clear context
        ↓ Continue working

Step 5: continue (in new session)
        ↓ Auto-load documents
        ↓ Resume from last task
```

### Switching Between Projects

If you have multiple projects in `dev/active/`:

```
Currently working on: royaltek-dashboard
Context usage: 70%

You: "Switch to web-ui-project"
  ↓
Claude: Auto-detects dev/active/web-ui-project/
Claude: Loads web-ui-project documents
Claude: Starts working on web-ui-project

Later:

You: "Go back to royaltek-dashboard"
  ↓
Claude: Auto-detects dev/active/royaltek-dashboard/
Claude: Loads royaltek-dashboard documents
Claude: Resumes exactly where it left off
```

---

## Development Rules

### Before Starting Implementation
- ✓ Load all three project documents
- ✓ Understand complete project structure
- ✓ Review implementation plan
- ✓ Check for any constraints or risks

### During Development
- ✓ Follow the plan.md structure strictly
- ✓ Refer to context.md for architecture decisions
- ✓ Check tasks.md for task details and dependencies
- ✓ Use code-format skill automatically
- ✓ Write clean, well-structured code

### After Completing Each Task
- ✓ Mark task as "Completed" in tasks.md
- ✓ Update progress percentage
- ✓ Add implementation notes
- ✓ Document any decisions made
- ✓ Move to next task

### When Context Gets Full (85%+)
- ✓ Run /update-dev-docs
- ✓ Save all progress to files
- ✓ Context is cleared
- ✓ Continue working

### Between Sessions
- ✓ Use "continue" command
- ✓ Claude auto-loads all documents
- ✓ Resume from exactly where you left off
- ✓ No context loss

---

## Example Usage

### Example 1: Start First Project

```
You: /dev-docs

Claude: What is the project name?
You: royaltek-dashboard

Claude: What is the project description?
You: Real-time data monitoring dashboard using PyQt5

Claude: (Planning mode - analyzing project)
Claude: (Generating documents)

✓ royaltek-dashboard-plan.md created
✓ royaltek-dashboard-context.md created
✓ royaltek-dashboard-tasks.md created

You: (Review documents)

You: Execute plan

Claude: Auto-detecting project...
Claude: Loading royaltek-dashboard documents...
Claude: Starting Phase 1 implementation...
Claude: Task 1.1: Setup Project Structure - IN PROGRESS
```

### Example 2: Start Another Project

```
You: /dev-docs

Claude: What is the project name?
You: web-ui-dashboard

Claude: What is the project description?
You: Web-based UI for device monitoring

Claude: (Planning mode)

✓ web-ui-dashboard-plan.md created
✓ web-ui-dashboard-context.md created
✓ web-ui-dashboard-tasks.md created

You: Execute plan

Claude: Auto-detecting project...
Claude: Found 2 projects - using most recent: web-ui-dashboard
Claude: Loading web-ui-dashboard documents...
Claude: Starting implementation...
```

### Example 3: Resume in New Session

```
New session starts

You: continue

Claude: Auto-loading dev/active/web-ui-dashboard/
Claude: Current progress: Phase 1 - 3/5 tasks completed
Claude: Resuming from Task 1.4...
Claude: (Continues exactly where it left off)
```

---

## Key Benefits

✅ **One-time setup** - Create CLAUDE.md once, use forever
✅ **Auto-detection** - Automatically finds current project
✅ **Multiple projects** - Supports unlimited projects simultaneously
✅ **No configuration** - New projects work automatically
✅ **Universal** - Same workflow for all projects
✅ **Seamless** - Smooth transitions between projects and sessions
✅ **Document preservation** - All progress saved in markdown files

---

## Important Notes

### CLAUDE.md is Read Every Time
- Claude Code reads this file at startup
- Every user input references this file
- Changes take effect immediately (after restart if needed)

### Auto-Detection Priority
- Most recently modified project is used by default
- Can explicitly switch projects by naming them
- No ambiguity - Claude always knows which project to work on

### Document Persistence
- All three documents stored in `dev/active/[project-name]/`
- Persistent across sessions
- Can be reviewed and edited anytime
- Can be versioned in git

### No Manual Loading Required
- Claude automatically loads all documents
- No "cat" commands needed from user
- Happens transparently in background
- User doesn't need to see file contents (but can if needed)

---

## Directory Setup

If `dev/` directory doesn't exist yet:

```bash
mkdir -p dev/active
mkdir -p dev/completed
```

This is done automatically by `/dev-docs` command, but you can set up manually.

---

## Troubleshooting

### Problem: "Cannot find dev/active/ directory"
**Solution**: Run `/dev-docs` first to create project

### Problem: Multiple projects - which one is being used?
**Solution**: Most recently modified project is used. Explicitly say project name to switch.

### Problem: Old documents not being updated
**Solution**: Run `/update-dev-docs` to ensure all changes are saved

### Problem: Context getting too full
**Solution**: Run `/update-dev-docs` to save progress and clear context

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `/dev-docs` | Create new project documentation |
| `Execute plan` | Start/continue project implementation |
| `/update-dev-docs` | Save progress, clear context |
| `continue` | Resume in new session |
| `Switch to [project]` | Switch between projects |

---

## Summary

This is a **universal, project-agnostic** development system that:

1. Creates comprehensive plans for any project
2. Automatically loads project documents when needed
3. Supports multiple projects with auto-detection
4. Preserves progress in markdown files
5. Enables seamless session resumption
6. Requires one-time setup and works forever

**One file, unlimited projects, complete automation.**
