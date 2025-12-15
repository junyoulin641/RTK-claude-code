#!/bin/bash

# Epic Show - Display epic status and information

# Parameters: project_name feature_name epic_name
project_name="$1"
feature_name="$2"
epic_name="$3"

if [ -z "$project_name" ] || [ -z "$feature_name" ] || [ -z "$epic_name" ]; then
  echo " Please provide project name, feature name, and epic name"
  echo "Usage: /pm:epic-show <project_name> <feature_name> <epic_name>"
  exit 1
fi

echo "Getting epic..."
echo ""
echo ""

epic_dir="./doc/$project_name/epics/$feature_name/$epic_name"
epic_file="$epic_dir.md"

if [ ! -f "$epic_file" ]; then
  echo " Epic not found: $epic_file"
  echo ""
  echo "Available epics in $project_name/$feature_name:"
  if [ -d "./doc/$project_name/epics/$feature_name" ]; then
    for file in ./doc/$project_name/epics/$feature_name/*.md; do
      [ -f "$file" ] && [ "$(basename "$file")" != "epic.md" ] && echo "  • $(basename "$file" .md)"
    done
  else
    echo "  (no epics directory found)"
  fi
  exit 1
fi

# Display epic details
echo " Epic: $epic_name"
echo "   Project: $project_name"
echo "   Feature: $feature_name"
echo "================================"
echo ""

# Extract metadata
status=$(grep "^status:" "$epic_file" | head -1 | sed 's/^status: *//')
progress=$(grep "^progress:" "$epic_file" | head -1 | sed 's/^progress: *//')
github=$(grep "^github:" "$epic_file" | head -1 | sed 's/^github: *//')
created=$(grep "^created:" "$epic_file" | head -1 | sed 's/^created: *//')

echo " Metadata:"
echo "  Status: ${status:-planning}"
echo "  Progress: ${progress:-0%}"
[ -n "$github" ] && echo "  GitHub: $github"
echo "  Created: ${created:-unknown}"
echo ""

# Show tasks
echo " Tasks:"
task_count=0
open_count=0
closed_count=0

if [ -d "$epic_dir" ]; then
  for task_file in "$epic_dir"/[0-9]*.md; do
    [ -f "$task_file" ] || continue

    task_num=$(basename "$task_file" .md)
    task_name=$(grep "^name:" "$task_file" | head -1 | sed 's/^name: *//')
    task_status=$(grep "^status:" "$task_file" | head -1 | sed 's/^status: *//')
    parallel=$(grep "^parallel:" "$task_file" | head -1 | sed 's/^parallel: *//')

    if [ "$task_status" = "closed" ] || [ "$task_status" = "completed" ]; then
      echo "    #$task_num - $task_name"
      ((closed_count++))
    else
      echo "    #$task_num - $task_name"
      [ "$parallel" = "true" ] && echo "      (parallel)"
      ((open_count++))
    fi

    ((task_count++))
  done
fi

if [ $task_count -eq 0 ]; then
  echo "  No tasks created yet"
  echo "  Run: /pm:epic-decompose $project_name $feature_name $epic_name"
fi

echo ""
echo " Statistics:"
echo "  Total tasks: $task_count"
echo "  Open: $open_count"
echo "  Closed: $closed_count"
[ $task_count -gt 0 ] && echo "  Completion: $((closed_count * 100 / task_count))%"

# Next actions
echo ""
echo " Actions:"
[ $task_count -eq 0 ] && echo "  • Decompose into tasks: /pm:epic-decompose $project_name $feature_name $epic_name"
[ -z "$github" ] && [ $task_count -gt 0 ] && echo "  • Sync to GitHub: /pm:epic-sync $project_name $feature_name $epic_name"
[ -n "$github" ] && [ "$status" != "completed" ] && echo "  • Start work: /pm:epic-start $project_name $feature_name $epic_name"
[ -n "$github" ] && [ $task_count -gt 0 ] && echo "  • Refresh progress: /pm:epic-refresh $project_name $feature_name $epic_name"

exit 0