---
allowed-tools: Bash, Read, Write, LS, Task
---

# Epic Sync

Push epic and tasks to GitHub as issues.

## Usage
```
/pm:epic-sync <project_name> <feature_name> <epic_name>
```

## Quick Check

1. **Verify parameters:**
   ```bash
   project_name="$1"
   feature_name="$2"
   epic_name="$3"
   
   [ -z "$project_name" ] || [ -z "$feature_name" ] || [ -z "$epic_name" ] && \
     echo "❌ Parameters missing. Please run: /pm:epic-sync <project_name> <feature_name> <epic_name>" && exit 1
   ```

2. **Verify epic exists:**
   ```bash
   epic_file="./doc/$project_name/epics/$feature_name/$epic_name.md"
   
   [ -f "$epic_file" ] || \
     echo "❌ Epic not found: $epic_file" && \
     echo "Run: /pm:prd-parse $project_name $feature_name" && exit 1
   ```

3. **Count task files:**
   ```bash
   epic_dir="./doc/$project_name/epics/$feature_name/$epic_name"
   task_count=$(ls "$epic_dir"/*.md 2>/dev/null | wc -l)
   
   [ "$task_count" -eq 0 ] && \
     echo "❌ No tasks found in: $epic_dir" && \
     echo "Run: /pm:epic-decompose $project_name $feature_name $epic_name" && exit 1
   ```

## Instructions

### 0. Check Remote Repository

Confirm the correct repository before syncing:

```bash
# Get current remote
remote_url=$(git remote get-url origin 2>/dev/null || echo "")
echo "📌 Current remote: $remote_url"
echo ""
echo "❓ Is this the correct repository? (yes/no)"
read -r user_confirm

if [ "$user_confirm" != "yes" ]; then
  echo "❌ Operation cancelled by user"
  echo ""
  echo "To update remote origin:"
  echo "  git remote set-url origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
  exit 1
fi
```

### 1. Create Epic Issue

```bash
epic_dir="./doc/$project_name/epics/$feature_name/$epic_name"
epic_file="./doc/$project_name/epics/$feature_name/$epic_name.md"

# Verify epic file exists
[ -f "$epic_file" ] || {
  echo "❌ Epic file not found: $epic_file"
  exit 1
}

# Get current repository
remote_url=$(git remote get-url origin 2>/dev/null || echo "")
REPO=$(echo "$remote_url" | sed 's|.*github.com[:/]||' | sed 's|\.git$||')

# Create labels if they don't exist
echo "📌 Creating labels if needed..."

gh label create \
  --repo "$REPO" \
  --name "epic" \
  --description "Epic - High-level feature group" \
  --color "3f51b5" \
  2>/dev/null || true

gh label create \
  --repo "$REPO" \
  --name "epic:$epic_name" \
  --description "Part of epic: $epic_name" \
  --color "2196f3" \
  2>/dev/null || true

gh label create \
  --repo "$REPO" \
  --name "task" \
  --description "Task - Actionable work item" \
  --color "4caf50" \
  2>/dev/null || true

gh label create \
  --repo "$REPO" \
  --name "feature:$feature_name" \
  --description "Part of feature: $feature_name" \
  --color "ff9800" \
  2>/dev/null || true

# Extract content without frontmatter using awk (more reliable)
epic_body=$(awk 'BEGIN{p=0} /^---$/{p++; next} p==2{print}' "$epic_file")
[ -z "$epic_body" ] && epic_body="See epic file: ./doc/$project_name/epics/$feature_name/$epic_name.md"

# Create epic issue with labels and body content
epic_output=$(gh issue create \
  --repo "$REPO" \
  --title "Epic: $epic_name" \
  --body "$epic_body" \
  --label "epic" \
  --label "epic:$epic_name" \
  --label "feature:$feature_name")

# Extract issue number from URL output (e.g., https://github.com/user/repo/issues/25)
epic_number=$(echo "$epic_output" | grep -oE 'issues/[0-9]+' | grep -oE '[0-9]+' || echo "")

if [ -z "$epic_number" ]; then
  echo "❌ Failed to create epic issue. Check GitHub permissions."
  exit 1
fi

echo "✅ Epic issue created: #$epic_number"
```

### 2. Create Task Sub-Issues

```bash
epic_dir="./doc/$project_name/epics/$feature_name/$epic_name"

# Check if gh-sub-issue is available
if gh extension list | grep -q "yahsan2/gh-sub-issue"; then
  use_subissues=true
else
  use_subissues=false
fi

# Create sub-issues for each task
for task_file in "$epic_dir"/[0-9]*.md; do
  [ -f "$task_file" ] || continue
  
  task_name=$(grep '^name:' "$task_file" | sed 's/^name: *//')
  
  # Extract body content without frontmatter using awk (more reliable)
  task_body=$(awk 'BEGIN{p=0} /^---$/{p++; next} p==2{print}' "$task_file")
  [ -z "$task_body" ] && task_body="See task file: $(basename "$task_file")"
  
  if [ "$use_subissues" = true ]; then
    # gh-sub-issue creates task as child of epic (establishes parent-child relationship)
    task_output=$(gh sub-issue create \
      --parent "$epic_number" \
      --title "$task_name" \
      --body "$task_body" \
      --label "task" \
      --label "feature:$feature_name" \
      --label "epic:$epic_name" 2>&1)
    # Extract from URL or #X format
    task_number=$(echo "$task_output" | grep -oE 'issues/[0-9]+' | grep -oE '[0-9]+' || echo "$task_output" | grep -oE '#[0-9]+' | head -1 | tr -d '#' || echo "")
    relationship_type="parent-child"
  else
    # Regular gh issue create (relates via label)
    task_output=$(gh issue create \
      --repo "$REPO" \
      --title "$task_name" \
      --body "$task_body" \
      --label "task" \
      --label "feature:$feature_name" \
      --label "epic:$epic_name" 2>&1)
    # Extract from URL output
    task_number=$(echo "$task_output" | grep -oE 'issues/[0-9]+' | grep -oE '[0-9]+' || echo "")
    relationship_type="label-based"
  fi
  
  if [ -n "$task_number" ]; then
    echo "$task_file:$task_number" >> /tmp/task-mapping.txt
    echo "✅ Created task #$task_number: $task_name ($relationship_type)"
  fi
done
```

### 3. Rename Task Files

```bash
epic_dir="./doc/$project_name/epics/$feature_name"

# Build ID mapping
> /tmp/id-mapping.txt
while IFS=: read -r task_file task_number; do
  old_num=$(basename "$task_file" .md)
  echo "$old_num:$task_number" >> /tmp/id-mapping.txt
done < /tmp/task-mapping.txt

# Rename files and update references
while IFS=: read -r task_file task_number; do
  new_name="$(dirname "$task_file")/${task_number}.md"
  
  content=$(cat "$task_file")
  while IFS=: read -r old_num new_num; do
    content=$(echo "$content" | sed "s/\b$old_num\b/$new_num/g")
  done < /tmp/id-mapping.txt
  
  echo "$content" > "$new_name"
  [ "$task_file" != "$new_name" ] && rm "$task_file"
  
  # Update frontmatter
  repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
  github_url="https://github.com/$repo/issues/$task_number"
  current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  sed -i.bak "/^github:/c\github: $github_url" "$new_name"
  sed -i.bak "/^updated:/c\updated: $current_date" "$new_name"
  rm "${new_name}.bak"
done < /tmp/task-mapping.txt
```

### 4. Update Epic File

```bash
epic_file="./doc/$project_name/epics/$feature_name/$epic_name.md"

repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
epic_url="https://github.com/$repo/issues/$epic_number"
current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

sed -i.bak "/^github:/c\github: $epic_url" "$epic_file"
sed -i.bak "/^updated:/c\updated: $current_date" "$epic_file"
rm "${epic_file}.bak"
```

### 5. Create Mapping File

```bash
epic_dir="./doc/$project_name/epics/$feature_name/$epic_name"

cat > "$epic_dir/github-mapping.md" << EOF
# GitHub Issue Mapping

Epic: #${epic_number} - https://github.com/${repo}/issues/${epic_number}

Tasks:
EOF

for task_file in "$epic_dir"/[0-9]*.md; do
  [ -f "$task_file" ] || continue
  
  issue_num=$(basename "$task_file" .md)
  task_name=$(grep '^name:' "$task_file" | sed 's/^name: *//')
  
  echo "- #${issue_num}: ${task_name}" >> "$epic_dir/github-mapping.md"
done

echo "" >> "$epic_dir/github-mapping.md"
echo "Synced: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$epic_dir/github-mapping.md"
```
## Output

```
✅ Synced to GitHub

📊 Summary:
  Project: $project_name
  Feature: $feature_name
  Epic: $epic_name (#${epic_number})
  
  - Epic Issue: #${epic_number}
  - Tasks Synced: ${task_count}
  - Relationship Type: parent-child (with gh-sub-issue) or label-based (without)
  - Labels Applied: epic, task, feature:$feature_name, epic:$epic_name
  - Mapping File: ./doc/$project_name/epics/$feature_name/$epic_name/github-mapping.md

🎯 Next Steps:
  - Start development: /pm:epic-start $project_name $feature_name $epic_name
  - View epic: https://github.com/$repo/issues/$epic_number
```

## Error Handling

If any step fails:
- Report what succeeded
- Note what failed
- Don't attempt rollback