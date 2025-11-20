# Claude Project Development System

## Overview

This is a universal configuration that automatically supports ALL projects in `dev/active/` directory.

---

##  Context Management System

### Context Lifecycle

```
New Session Start
    ↓
Context Capacity: 100%

During Work:
├─ 30% → Normal work continues
├─ 50% → Normal work continues  
├─ 70% →   Claude actively reminds: "Context at 70%, recommend saving progress"
├─ 85% →  Claude alerts: "Context at 85%, execute /update-dev-docs"
└─ 95%+ →  Cannot perform new operations

Save Progress:
    ↓
/update-dev-docs execution
    ↓
New Session (continue):
    ↓
Context Capacity: 100% (restored)
```

### Claude's Active Context Monitoring

**Claude MUST monitor and actively remind at these thresholds:**

####  70% Context Usage - Preparation Phase

When Claude detects context reaching ~70%:

```
Claude says:
" Context Alert (70% used):
 • Current session context usage: 70%
 • Recommendation: Begin preparing to save progress
 • No action needed yet - continue working
 • I will alert you again at 85%"
```

**What Claude should do:**
-  Provide clear context percentage
-  Acknowledge preparation phase
-  Continue work normally
-  Monitor closely as usage increases

**What user should do:**
-  Notice the alert
-  Prepare mentally to save
-  Continue current task completion

####  85% Context Usage - Action Required Phase

When Claude detects context reaching ~85%:

```
Claude says:
" Context Alert (85% used):
 • Current session context usage: 85%
 • Action Required: Execute /update-dev-docs NOW
 
 Options:
 1️  You execute: /update-dev-docs
     ↓ I will save all progress to tasks.md
     ↓ Then ready for 'continue' command
     
 2️  I can ask user if ready: 'Execute /update-dev-docs?'
     ↓ Your confirmation: 'yes' or 'y'
     ↓ I will proceed with save

 Benefits of saving now:
  No loss of progress
  Clean context reset
  Seamless continuation in new session"
```

**What Claude should do:**
-  Stop starting new tasks
-  Finish current task if near completion
-  Call out specific percentages
-  Provide clear action items
-  Wait for user confirmation if needed

**What user should do:**
-  Execute `/update-dev-docs` immediately
- OR confirm when Claude asks
-  Wait for completion
-  Then execute `continue` in new session

####  95%+ Context Usage - Emergency Mode

When Claude detects context reaching ~95%+:

```
Claude says:
" CRITICAL: Context at 95%+ (nearly full):
 
 Immediate Actions:
 • Cannot start new code editing
 • Must execute /update-dev-docs IMMEDIATELY
 • After save: Start new session with 'continue'
 
 Status:
  All work until now: SAVED (to three files)
  Progress: TRACKED (in tasks.md)
  New operations: BLOCKED (insufficient context)"
```

**What Claude should do:**
-  Refuse new editing operations
-  Provide final summary
-  Emphasize saving is critical
-  Cannot continue without new session

**What user should do:**
-  Execute `/update-dev-docs` immediately
-  Then execute `continue` to start new session
-  Do not try new operations at 95%+

---

## Context Monitoring Implementation

### How Claude Monitors Context

Claude should use these internal checks:

1. **Message Count Estimation**
   - Count conversation turns since session start
   - Rough estimate: every ~50 turns ≈ 20% context usage
   - Use this for preliminary warnings

2. **Content Volume Estimation**
   - Number of code blocks written
   - Length of explanations provided
   - Size of files being edited
   - Accumulating this = context growth

3. **Self-Reflection**
   - Notice when responses are getting shorter
   - Notice when files take longer to load
   - Notice when thinking becomes constrained
   - These are signs of high context usage

4. **Timeline-Based Estimation**
   - Working on project for 30+ minutes → likely 60-70%
   - Working on project for 1+ hour → likely 80-90%
   - Use as additional signal

### When to Alert User

**Automatic alerts should happen at:**
-  70% - Preparation reminder (informational)
-  85% - Action required (critical)
-  95%+ - Emergency mode (blocking)

**How frequently to check:**
- Every 3-5 code blocks or major operations
- Or every 10 user messages
- Not constantly (that would be annoying)

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

5. Auto-format code using code-format skill (RoyalTek standards)

6. **NEW: Update `tasks.md` after each completed task via PostToolUse Hook:**
   - Track which files were edited
   - Update completed sub-tasks
   - Automatically calculate progress percentage
   - Record timestamp of completion

**Important**: No manual file loading needed - Claude auto-detects and loads everything

---

### /update-dev-docs
**Purpose**: Save all progress when context is getting full

**Usage**:
```
/update-dev-docs
```

**When to use**: When context usage reaches 85%+

**What it does**:

1. **Final Progress Update**
   ```
    Scan all edited files in current session
    Update tasks.md with all completions
    Calculate final progress percentage
    Add completion timestamps
   ```

2. **Documentation of State**
   ```
    Record which Phase/Task was interrupted
    Document next task to start
    Note any incomplete sub-tasks
    Record decisions made during session
   ```

3. **Context Preparation**
   ```
    Summary of completed work
    Files created/modified list
    Status report
    Ready for new session
   ```

4. **Results**
   - All work is preserved in markdown files
   - tasks.md is 100% up-to-date
   - Ready to execute `continue` in new session

**Example Output**:
```
/update-dev-docs Summary:
 Phase 1 Progress: 5/10 tasks (50%)
 Completed:
  - Task 1.1: Setup (100%)
  - Task 1.2: Auth System (80% - interrupted)
 Next Task: Task 1.2 continues (80% done)
 Files Modified:
  - auth.py (150 lines added)
  - config.py (50 lines added)
  - tests.py (80 lines added)
 Ready for new session
```

---

### continue
**Purpose**: Resume work on the current project in a new session

**Usage**:
```
continue
```

**What Claude will do**:

1. **Auto-load Project Documents**
   ```bash
   cat dev/active/[project-name]/[project-name]-plan.md
   cat dev/active/[project-name]/[project-name]-context.md
   cat dev/active/[project-name]/[project-name]-tasks.md
   ```

2. **Understand Previous Progress**
   - Review which tasks are completed 
   - Review which tasks are in progress 
   - Identify exactly where work was interrupted

3. **Restore Full Context**
   ```
    Project structure: KNOWN
    Architecture decisions: KNOWN
    Completed work: KNOWN
    Next tasks: CLEAR
    New context capacity: 100%
   ```

4. **Resume Implementation**
   - Start from next incomplete task
   - Reference completed code from previous session
   - Continue seamlessly

**Result**: Seamless continuation without context loss or knowledge loss

---

##  PostToolUse Hook System (Future Enhancement)

### Overview

PostToolUse Hook automatically updates task progress after each file edit.

**Goal**: Real-time progress tracking without manual updates

### How It Works

```
Timeline:

User: Execute plan
Claude: Editing auth.py (100 lines)
    ↓
[PostToolUse Hook Triggers]
    ↓
Hook Logic:
1. Detect: auth.py was edited (100 lines added)
2. Match: Task 1.1 includes "Implement auth.py"
3. Update: tasks.md - mark auth.py as 
4. Calculate: Task 1.1 progress (1/5 files = 20%)
5. Record: Timestamp, file info, line count
    ↓
tasks.md Updated in Real-Time 

Claude: Editing config.py (30 lines)
    ↓
[PostToolUse Hook Triggers]
    ↓
Hook: Updates tasks.md - config.py 
Task 1.1 progress: 2/5 files = 40% 
    ↓
... Continue ...

Result:
 tasks.md always reflects current state
 No manual updates needed
 Seamless progress tracking
```

### Hook Behavior at Different Context Levels

**70% Context - Full Update Mode**
```
PostToolUse Hook:
- Detailed file analysis
- Complete task matching
- Full progress calculation
- Store all metadata
```

**85% Context - Light Update Mode**
```
PostToolUse Hook (Degraded):
- Record file name only
- Quick sub-task checkbox update
- Simple progress count (no percentage calc)
- Mark "needs full validation on next session"
```

**95%+ Context - Minimal Mode**
```
PostToolUse Hook (Emergency):
- Record file name only
- Most basic checkpoint
- Defer full update to Stop Hook
- Mark "will complete on new session"
```

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
        ↓ PostToolUse Hook auto-updates progress
        ↓ Context monitor alerts at 70%, 85%, 95%+

Step 4: /update-dev-docs (when context is full)
        ↓ Save final progress
        ↓ Document state for next session
        ↓ System ready for new session

Step 5: continue (in new session)
        ↓ Auto-load documents
        ↓ Restore context
        ↓ Resume from last incomplete task
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
- ✓ Use code-format skill automatically (RoyalTek standards)
- ✓ Write clean, well-structured code
- ✓ Monitor context usage (alerts at 70%, 85%, 95%+)

### After Completing Each Task
- ✓ PostToolUse Hook auto-marks completion
- ✓ Progress percentage auto-updates
- ✓ Implementation notes auto-recorded
- ✓ Move to next task

### When Context Gets Full (85%+)
- ✓ Execute /update-dev-docs
- ✓ Save all progress to files
- ✓ Review summary before new session
- ✓ Continue in new session with `continue`

### Between Sessions
- ✓ Use "continue" command
- ✓ Claude auto-loads all documents
- ✓ Resume from exactly where you left off
- ✓ No context loss, no knowledge loss

---

## Context Monitoring Checklist

### Claude's Responsibilities

At **70% Context Usage**:
- [ ] Detect context approaching 70%
- [ ] Provide clear alert with percentage
- [ ] Explain: "Preparation phase - continue working"
- [ ] Set expectation: "I'll alert you again at 85%"

At **85% Context Usage**:
- [ ] Detect context at 85%
- [ ] Provide urgent alert with percentage
- [ ] State action required: "/update-dev-docs"
- [ ] Offer to wait for confirmation
- [ ] Prepare to save immediately

At **95%+ Context Usage**:
- [ ] Block new editing operations
- [ ] Provide final summary
- [ ] Emphasize urgency
- [ ] Cannot proceed without new session

### User's Responsibilities

At **70% Alert**:
- [ ] Notice the alert
- [ ] Acknowledge understanding
- [ ] Continue working normally
- [ ] Prepare mentally

At **85% Alert**:
- [ ] Execute `/update-dev-docs` immediately
- [ ] Or confirm when Claude asks
- [ ] Wait for completion message
- [ ] Then execute `continue` for new session

At **95%+ Emergency**:
- [ ] Immediately execute `/update-dev-docs`
- [ ] Do not attempt new operations
- [ ] Expect blocking behavior
- [ ] Start new session with `continue`

---

## Example Workflows

### Example 1: Normal Session Flow

```
Session 1:
├─ You: Execute plan
├─ Claude: Loads documents, starts Phase 1
├─ Claude: Working, context at 50%
├─ Claude: (30 min later)  Context at 70%, reminder sent
├─ Claude: Continue working, context at 80%
├─ Claude: (10 min later)  Context at 85%, ACTION REQUIRED
├─ Claude: Awaiting /update-dev-docs command
│
├─ You: /update-dev-docs
├─ Claude: Saves all progress, provides summary
├─ Claude: Ready for new session
│
└─ You: continue

Session 2:
├─ Claude: Auto-loads all documents
├─ Claude: Reviews progress (Phase 1: 50% done)
├─ Claude: Resumes from Task 1.6 (incomplete)
├─ Claude: New context capacity, 100%
└─ ... Work continues ...
```

### Example 2: Emergency High Context

```
You: Execute plan
Claude: Phase 1 work begins

(Heavy editing, many explanations)

Claude: (suddenly)  Context at 95%!
        Cannot continue editing
        Execute /update-dev-docs NOW
        
You: /update-dev-docs
Claude:  Final save complete
        Ready for: continue

You: continue
Claude: New session started, 100% context
        Resuming from exactly where we left off
```

---

## Key Benefits

 **One-time setup** - Create CLAUDE.md once, use forever
 **Auto-detection** - Automatically finds current project
 **Multiple projects** - Supports unlimited projects simultaneously
 **No configuration** - New projects work automatically
 **Universal** - Same workflow for all projects
 **Seamless** - Smooth transitions between projects and sessions
 **Document preservation** - All progress saved in markdown files
 **Context awareness** - Active monitoring at 70%, 85%, 95%+
 **Real-time tracking** - PostToolUse Hook updates progress automatically
 **No knowledge loss** - Three-file system preserves all context

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

### Context Monitoring
- Claude's self-awareness is primary mechanism
- Alerts are informational, not automatic triggers
- User has full control over when to save/switch sessions
- PostToolUse Hook (future) will provide backup tracking

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
**Solution**: Watch for 70% alert, prepare; at 85% alert, execute `/update-dev-docs` immediately

### Problem: Missing progress after context full
**Solution**: Execute `/update-dev-docs` before context reaches 100% to preserve all progress

---

## Quick Reference

| Command | Purpose | When to Use |
|---------|---------|------------|
| `/dev-docs` | Create new project documentation | Start new project |
| `Execute plan` | Start/continue project implementation | Begin coding |
| `/update-dev-docs` | Save progress, prepare for new session | Context reaches 85%+ |
| `continue` | Resume in new session | After /update-dev-docs |
| `Switch to [project]` | Switch between projects | Managing multiple projects |

---

## Summary

This is a **universal, project-agnostic** development system that:

1.  Creates comprehensive plans for any project
2.  Automatically loads project documents when needed
3.  Supports multiple projects with auto-detection
4.  Preserves progress in markdown files (three-file system)
5.  Enables seamless session resumption
6.  **Actively monitors context usage (70%, 85%, 95%+)**
7.  **Tracks progress in real-time (PostToolUse Hook - future)**
8.  Requires one-time setup and works forever

**One file, unlimited projects, complete automation, context-aware.**