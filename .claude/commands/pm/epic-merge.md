---
allowed-tools: Bash, Read, Write
---

# Epic Merge

Merge completed epic from worktree back to main branch.

## Usage
```
/pm:epic-merge <project_name> <feature_name> <epic_name>
```

## Required Rules

**IMPORTANT:** Before executing this command, read and follow:
- `.claude/rules/datetime.md` - For getting real current date/time

## Quick Check

1. **Verify parameters:**
   - Check if all three `<project_name>`, `<feature_name>`, `<epic_name>` were provided
   - If not, tell user: " Parameters missing. Please run: /pm:epic-merge <project_name> <feature_name> <epic_name>"

2. **Verify worktree exists:**
   ```bash
   git worktree list | grep "epic-$feature_name" || echo " No worktree for epic: $feature_name"
   ```

3. **Check for active agents:**
   Read `./doc/$project_name/epics/$feature_name/$epic_name/execution-status.md`
   If active agents exist: " Active agents detected. Stop them first with: /pm:epic-stop $project_name $feature_name $epic_name"

## Instructions

### 1. Pre-Merge Validation in Worktree

Enter the epic worktree and validate:
```bash
# Navigate to worktree
worktree_dir="../epic-$feature_name"

echo " Entering worktree for validation: $worktree_dir"
cd "$worktree_dir" || {
  echo "❌ Cannot access worktree: $worktree_dir"
  exit 1
}

echo "✓ Current location: $(pwd)"
echo "✓ Current branch: $(git branch --show-current)"

# Check for uncommitted changes
if [[ $(git status --porcelain) ]]; then
  echo " Uncommitted changes in worktree:"
  git status --short
  echo ""
  echo "Commit or stash changes before merging"
  exit 1
fi

echo "✓ No uncommitted changes"

# Check branch status
echo ""
echo "Fetching latest from remote..."
git fetch origin
git status -sb
```

### 2. Run Tests (Optional but Recommended)

```bash
# Look for test commands based on project type
if [ -f package.json ]; then
  npm test || echo " Tests failed. Continue anyway? (yes/no)"
elif [ -f pom.xml ]; then
  mvn test || echo " Tests failed. Continue anyway? (yes/no)"
elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then
  ./gradlew test || echo " Tests failed. Continue anyway? (yes/no)"
elif [ -f composer.json ]; then
  ./vendor/bin/phpunit || echo " Tests failed. Continue anyway? (yes/no)"
elif [ -f *.sln ] || [ -f *.csproj ]; then
  dotnet test || echo " Tests failed. Continue anyway? (yes/no)"
elif [ -f Cargo.toml ]; then
  cargo test || echo " Tests failed. Continue anyway? (yes/no)"
elif [ -f go.mod ]; then
  go test ./... || echo " Tests failed. Continue anyway? (yes/no)"
elif [ -f Gemfile ]; then
  bundle exec rspec || bundle exec rake test || echo " Tests failed. Continue anyway? (yes/no)"
elif [ -f pubspec.yaml ]; then
  flutter test || echo " Tests failed. Continue anyway? (yes/no)"
elif [ -f Package.swift ]; then
  swift test || echo " Tests failed. Continue anyway? (yes/no)"
elif [ -f CMakeLists.txt ]; then
  cd build && ctest || echo " Tests failed. Continue anyway? (yes/no)"
elif [ -f Makefile ]; then
  make test || echo " Tests failed. Continue anyway? (yes/no)"
fi
```

### 3. Update Epic Documentation

Get current datetime: `date -u +"%Y-%m-%dT%H:%M:%SZ"`

Update `./doc/$project_name/epics/$feature_name/$epic_name.md`:
- Set status to "completed"
- Update completion date
- Add final summary

```bash
# This path is relative to worktree root
epic_file="./doc/$project_name/epics/$feature_name/$epic_name.md"

if [ -f "$epic_file" ]; then
  current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  sed -i.bak "s/^status:.*/status: completed/" "$epic_file"
  sed -i.bak "s/^completed:.*/completed: $current_date/" "$epic_file"
  rm -f "${epic_file}.bak"
  echo "✓ Epic documentation updated"
fi
```

### 4. Prepare for Merge

Commit any pending changes and prepare merge commit message:

```bash
# Make sure everything is committed
if [[ $(git status --porcelain) ]]; then
  echo " Staging final changes..."
  git add .
  git commit -m "Epic completion: Final documentation update"
fi

# Get epic issue number from github URL
epic_github=$(grep '^github:' ./doc/$project_name/epics/$feature_name/$epic_name.md 2>/dev/null | sed 's/^github: *//' || echo "")

# Generate task list from task files
task_list=""
for task_file in ./doc/$project_name/epics/$feature_name/$epic_name/[0-9]*.md; do
  [ -f "$task_file" ] || continue
  task_name=$(grep '^name:' "$task_file" | sed 's/^name: *//')
  task_list="$task_list- $task_name"$'\n'
done

# Prepare merge message
merge_message="Merge epic: $epic_name ($feature_name)

Project: $project_name
Feature: $feature_name
Epic: $epic_name

Completed tasks:
$task_list"

if [ -n "$epic_github" ]; then
  merge_message="$merge_message

GitHub: $epic_github"
fi

echo "✓ Merge prepared, ready to return to main directory"
```

### 5. Return to Main Directory and Merge

Now return to the main project directory and perform the merge:

```bash
# Navigate back to main project directory
# Current location: ../epic-$feature_name
# Target location: ../pt (or your main directory name)

echo ""
echo " Returning to main project directory..."

# Go up two levels and find the main directory
# This assumes structure: /path/pt/ (main) and /path/epic-$feature_name/ (worktree)
cd ../

# Find main project directory (contains .git and .claude)
main_dir=$(find . -maxdepth 1 -type d -name 'pt' -o -type d -path '*/.git' -prune -o -type d -name 'pt' 2>/dev/null | head -1)

if [ -z "$main_dir" ]; then
  # Fallback: look for directory with .claude and .git
  main_dir=$(find . -maxdepth 1 -type d \( -name 'pt' -o -name 'main' \) 2>/dev/null | head -1)
fi

if [ -z "$main_dir" ]; then
  echo "❌ Cannot find main project directory"
  echo "Please manually navigate to your main project directory containing .git and .claude/"
  exit 1
fi

cd "$main_dir" || {
  echo "❌ Cannot access main directory: $main_dir"
  exit 1
}

echo "✓ Current location: $(pwd)"
echo "✓ Directory contents:"
ls -la | grep -E '^\.|.git|.claude|doc'

# Ensure main is up to date
echo ""
echo " Preparing main branch..."
git checkout main || {
  echo "❌ Failed to checkout main branch"
  exit 1
}

git pull origin main || {
  echo "⚠️ Could not pull main (may already be up to date)"
}

# Perform the merge
echo ""
echo " Merging epic/$epic_name to main..."
if git merge epic/$epic_name --no-ff -m "$merge_message"; then
  echo "✓ Merge successful!"
else
  # Merge failed - likely conflicts
  echo "❌ Merge conflicts detected"
  exit 1
fi
```

### 6. Handle Merge Conflicts

If merge fails with conflicts:
```bash
# Check conflict status
git status

echo "
 Merge conflicts detected!

Conflicts in:
$(git diff --name-only --diff-filter=U)

Options:
1. Resolve manually:
   - Edit conflicted files
   - git add {files}
   - git commit
   
2. Abort merge:
   git merge --abort
   
3. Get help:
   /pm:epic-resolve $project_name $feature_name $epic_name

Worktree preserved at: ../epic-$feature_name/
All worktree data is safe.
"
exit 1
```

### 7. Post-Merge Cleanup

If merge succeeds:
```bash
# Push to remote
echo ""
echo " Pushing merged code to remote..."
git push origin main || {
  echo "⚠️ Could not push to remote, but merge is local"
}

echo " Cleaning up epic branch and worktree..."

# Clean up worktree (from main directory)
worktree_path="../epic-$feature_name"
if [ -d "$worktree_path" ]; then
  git worktree remove "$worktree_path" --force || {
    echo "⚠️ Could not remove worktree, trying alternative method..."
    rm -rf "$worktree_path"
  }
  echo "✓ Worktree removed: $worktree_path"
fi

# Delete branch
git branch -d epic/$epic_name || {
  echo "⚠️ Local branch already deleted"
}
git push origin --delete epic/$epic_name 2>/dev/null || {
  echo "⚠️ Remote branch already deleted"
}
echo "✓ Branch deleted: epic/$epic_name"

# Archive epic locally
mkdir -p ./doc/$project_name/epics/$feature_name/.archived/
if [ -d "./doc/$project_name/epics/$feature_name/$epic_name" ]; then
  mv ./doc/$project_name/epics/$feature_name/$epic_name ./doc/$project_name/epics/$feature_name/.archived/
  echo "✓ Epic archived: ./doc/$project_name/epics/$feature_name/.archived/$epic_name"
fi

if [ -f "./doc/$project_name/epics/$feature_name/$epic_name.md" ]; then
  mv ./doc/$project_name/epics/$feature_name/$epic_name.md ./doc/$project_name/epics/$feature_name/.archived/$epic_name.md
  echo "✓ Epic file archived"
fi
```

### 8. Update GitHub Issues

Close related issues:
```bash
# Get repo
remote_url=$(git remote get-url origin 2>/dev/null || echo "")
REPO=$(echo "$remote_url" | sed 's|.*github.com[:/]||' | sed 's|\.git$||')

epic_file="./doc/$project_name/epics/$feature_name/.archived/$epic_name.md"

if [ -f "$epic_file" ]; then
  epic_github_line=$(grep 'github:' "$epic_file" 2>/dev/null || true)
  if [ -n "$epic_github_line" ]; then
    epic_issue=$(echo "$epic_github_line" | grep -oE '[0-9]+$' || true)
  else
    epic_issue=""
  fi
  
  # Close epic issue
  if [ -n "$epic_issue" ]; then
    gh issue close "$epic_issue" --repo "$REPO" -c "Epic completed and merged to main"
    echo "✓ Closed epic issue #$epic_issue"
  fi
  
  # Close task issues
  epic_dir="./doc/$project_name/epics/$feature_name/.archived/$epic_name"
  if [ -d "$epic_dir" ]; then
    for task_file in "$epic_dir"/[0-9]*.md; do
      [ -f "$task_file" ] || continue
      task_github_line=$(grep 'github:' "$task_file" 2>/dev/null || true)
      if [ -n "$task_github_line" ]; then
        issue_num=$(echo "$task_github_line" | grep -oE '[0-9]+$' || true)
      else
        issue_num=""
      fi
      if [ -n "$issue_num" ]; then
        gh issue close "$issue_num" --repo "$REPO" -c "Completed in epic merge"
        echo "✓ Closed task issue #$issue_num"
      fi
    done
  fi
fi
```

### 9. Final Output

```
✓ Epic Merged Successfully: $epic_name
   Project: $project_name
   Feature: $feature_name

Summary:
  Branch: epic/$epic_name → main
  Commits merged: {count}
  Files changed: {count}
  Issues closed: {count}
  
Cleanup completed:
  ✓ Worktree removed: ../epic-$feature_name
  ✓ Branch deleted: epic/$epic_name
  ✓ Epic archived: ./doc/$project_name/epics/$feature_name/.archived/$epic_name
  ✓ GitHub issues closed
  
Current location: $(pwd)
Current branch: $(git branch --show-current)

Next steps:
  - Deploy changes if needed
  - Start new epic: /pm:project-feature $project_name --add {new_feature}
  - View completed work: git log --oneline -20
  - View epic archive: ls ./doc/$project_name/epics/$feature_name/.archived/
```

## Conflict Resolution Help

If conflicts need resolution:
```
The epic branch has conflicts with main.

This typically happens when:
- Main has changed since epic started
- Multiple epics modified same files
- Dependencies were updated

To resolve:
1. You are currently in the main project directory
2. Open conflicted files shown by: git status
3. Look for <<<<<<< markers
4. Choose correct version or combine
5. Remove conflict markers
6. git add {resolved files}
7. git commit
8. git push

Or abort and try later:
  git merge --abort
  # Worktree preserved at ../epic-$feature_name
```

## Important Notes

- **Section 1**: Validation happens IN the worktree
- **Section 4-5**: Merge happens in MAIN project directory
- Always check for uncommitted changes first
- Run tests before merging when possible
- Use --no-ff to preserve epic history
- Archive epic data instead of deleting
- Close GitHub issues to maintain sync
- Worktree is preserved during merge (allows rollback if needed)