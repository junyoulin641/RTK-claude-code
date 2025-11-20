---
name: update-dev-docs
description: "Update and save all progress to tasks.md. Performs complete verification and generates session report. Can be executed anytime to update progress."
---

## /update-dev-docs Command

**Purpose**: Update and save all progress to tasks.md with complete verification

**When to execute**: Anytime you want to update progress (recommended before starting new session)

**What it does**: 
- Scans all edited files in current session
- Performs complete verification of edits
- Updates tasks.md with detailed information
- Calculates final progress percentage
- Generates comprehensive session report
- Prepares for seamless continuation

---

## Execution Logic

### Step 1: Scan All Edited Files

I will check all files edited in this session:

```bash
# Scan from Git status or file modification time
git status --short  # If Git repository
find . -type f -mmin -120  # Files modified in last 2 hours
```

I will detect:
- Files that were edited
- Line count changes
- File types and languages
- Edit timestamps

### Step 2: Verify Project Location

I will locate the tasks.md file:

```bash
find dev/active -name "tasks.md" -type f
```

Priority order:
1. `dev/active/[project-name]/tasks.md`
2. `dev/active/tasks.md`
3. `dev/tasks.md`
4. Current directory `tasks.md`

### Step 3: Complete Verification and Update

Unlike the PostToolUse Hook's lightweight updates, `/update-dev-docs` performs:

**1. Complete Verification**
- Check all edited file contents
- Verify file integrity
- Validate against project requirements

**2. Precise Matching**
- Match files exactly with tasks in tasks.md
- Identify which tasks each file belongs to
- Calculate task completion rates

**3. Detailed Update**
- Update file information (line count, language, timestamp)
- Mark all edited files as completed
- Update sub-task status
- Calculate completion percentage

**4. Progress Calculation**
- Count completed files/tasks
- Calculate total progress percentage
- Track progress at multiple levels (file, task, phase)

**5. Decision Recording**
- Record all decisions made during session
- Document architecture choices
- Note any challenges encountered

### Step 4: Generate Complete Session Report

Append to tasks.md:

```markdown
====================================
Session Completion Report [YYYY-MM-DD HH:MM:SS]
====================================

Progress Summary:
  • Current Progress: 50% (5/10 tasks)
  • Completed Tasks:
    - Task 1.1: Setup (100%)
    - Task 1.2: Authentication (90%)
  • Pending Tasks:
    - Task 1.3: Database Layer (0%)

Edited Files:
  ✅ auth.py (150 lines)
  ✅ config.py (50 lines)
  ✅ tests.py (80 lines)

Next Session Start:
  → Task 1.3: Implement Database Layer

Important Decisions:
  • Use PostgreSQL instead of MongoDB
  • Implement ORM layer instead of raw SQL

Notes:
  • auth.py password hashing function needs salt value
  • Need to add more unit test coverage
  • Consider adding API documentation

====================================
```

### Step 5: Display Summary and Prepare New Session

Output clear summary:

```
✅ /update-dev-docs completed

📊 Progress Summary:
  • Progress: 50% (5/10 tasks)
  • Completed Files: 3
  • Total Lines Added: 280

📝 Edited Files:
  ✅ auth.py (150 lines)
  ✅ config.py (50 lines)
  ✅ tests.py (80 lines)

🎯 Next Task:
  → Task 1.3: Implement Database Layer

⏳ Ready!
   Execute 'continue' command to start new session
```

---

## Detailed Implementation Steps

### Step 1: Scan and Count

```
Scan edited files:
  • Use git status if Git repository exists
  • Use find for file modification time otherwise
  • Count edited files and total line additions
```

### Step 2: Locate tasks.md

```
Search hierarchy:
  1. dev/active/[project-name]/tasks.md
  2. dev/active/tasks.md
  3. dev/tasks.md
  4. Current directory tasks.md

If not found, report error and stop
```

### Step 3: Complete Verification

```
For each edited file:
  1. Find corresponding task in tasks.md
  2. Verify filename and path match
  3. Get detailed file information
  4. Determine completion status
  5. Record all metadata
```

### Step 4: Update tasks.md

```
Update operations:
  • Mark all edited files as [x]
  • Add completion timestamps
  • Calculate sub-task completion ratio
  • Calculate overall progress percentage
  • Add session report with full details
```

### Step 5: Generate Session Report

```
Report includes:
  ✅ Execution timestamp
  ✅ Progress percentage
  ✅ Completed task list
  ✅ Edited file list with line counts
  ✅ Next task to start
  ✅ Important decisions made
  ✅ Implementation notes
  ✅ Challenges encountered
```

### Step 6: Display Final Summary

```
Inform user:
  ✅ All progress saved
  ✅ tasks.md updated
  ✅ Session report added
  ✅ Ready to execute 'continue'
```

---

## Usage Example

### When executing /update-dev-docs

**You execute**:
```
/update-dev-docs
```

**I respond with**:
```
🔄 Executing /update-dev-docs...

Step 1: Scanning edited files...
  ✅ Detected 3 edits
     • auth.py
     • config.py
     • tests.py

Step 2: Locating tasks file...
  ✅ Found: dev/active/my-project/tasks.md

Step 3: Complete verification...
  ✅ auth.py → Task 1.2: Authentication
  ✅ config.py → Task 1.1: Setup
  ✅ tests.py → Task 1.2: Authentication

Step 4: Updating progress...
  ✅ Mark files as completed
  ✅ Calculate progress: 50%
  ✅ Add session report

✅ /update-dev-docs completed

📊 Progress Summary:
  • Progress: 50% (5/10 tasks)
  • Completed Files: 3
  • Total Lines Added: 280

🎯 Next Task:
  → Task 1.3: Implement Database Layer

⏳ Ready!
   Execute 'continue' command to start new session
```

**You execute**:
```
continue
```

**I respond with**:
```
Claude: Auto-loading all documents...

✅ Documents loaded:
  • plan.md ✅
  • context.md ✅
  • tasks.md ✅

📊 Progress restored:
  • Current progress: 50% (5/10 tasks)
  • Completed: Task 1.1, Task 1.2
  • Pending: Task 1.3 ~ Task 1.10

🎯 Next Task:
  → Task 1.3: Implement Database Layer

⏳ New context capacity: 100%

Starting Task 1.3 implementation...
```

---

## Complete Implementation

### Pseudocode

```
function update_dev_docs():
    # Step 1: Scan
    edited_files = scan_edited_files()
    
    # Step 2: Locate
    tasks_file = find_tasks_file()
    if not tasks_file:
        print "❌ Cannot find tasks.md"
        return
    
    # Step 3: Verify
    for each file in edited_files:
        matching_task = find_matching_task(file, tasks_file)
        verify_file_content(file)
        get_file_info(file)  # line count, language, etc.
    
    # Step 4: Update
    for each file in edited_files:
        update_task_status(file, tasks_file, "completed")
        add_completion_time(file, tasks_file)
    
    # Step 5: Calculate
    completed = count_completed_tasks(tasks_file)
    total = count_all_tasks(tasks_file)
    progress = (completed / total) * 100
    
    # Step 6: Report
    add_session_report(tasks_file, {
        timestamp: current_time,
        progress: progress,
        completed_files: edited_files,
        next_task: find_next_incomplete_task(tasks_file),
        decisions: [],
        notes: []
    })
    
    # Step 7: Summary
    print_summary(edited_files, progress)
    print "Ready to execute 'continue'"
```

---

## Key Differences from PostToolUse Hook

| Item | PostToolUse Hook | /update-dev-docs |
|------|-----------------|-----------------|
| **Trigger** | After each file edit | User executes command |
| **Frequency** | Frequent (per file) | Once when needed |
| **Verification** | Lightweight | Complete |
| **Detail Level** | Basic (filename, time) | Detailed (all metadata) |
| **Performance** | Low overhead | Medium overhead |
| **Accuracy** | Medium | High |
| **When to use** | Continuous tracking | Session completion |
| **Required** | No (auto) | Yes (manual) |

---

## Checklist for /update-dev-docs Execution

When executing /update-dev-docs, verify:

- [ ] All edited files detected?
- [ ] Found tasks.md file?
- [ ] All files matched to correct tasks?
- [ ] Progress percentage calculated correctly?
- [ ] Session report added?
- [ ] Next task clearly specified?
- [ ] Final summary displayed correctly?

---

## FAQ

### Q: When should I execute /update-dev-docs?

A: You can execute it anytime, but optimal moments are:
- Before starting a new session
- When context is high (85%+)
- After completing a significant task
- When you want to save progress explicitly

### Q: What's the difference between PostToolUse Hook and /update-dev-docs?

A:
- **Hook**: Runs frequently, lightweight, continuous tracking
- **/update-dev-docs**: Runs once per session, complete verification, detailed reporting

### Q: What if tasks.md is not found?

A:
- Command will report error
- No automatic update will occur
- Create tasks.md using /dev-docs command first

### Q: Can I execute /update-dev-docs multiple times?

A:
- Yes, you can execute it multiple times
- Each execution will update progress
- Multiple reports will be added to tasks.md

### Q: Does /update-dev-docs clear the context?

A:
- No, it only updates tasks.md
- To clear context, execute 'continue' to start new session
- Context is managed automatically by Claude Code

---

## Next Steps

After executing `/update-dev-docs`:

1. ✅ Check tasks.md is updated correctly
2. ✅ Verify session report content
3. ✅ Confirm next task is clearly specified
4. ✅ Execute 'continue' to start new session
5. ✅ New session automatically loads all documents
6. ✅ Seamless progress recovery and continuation

---
