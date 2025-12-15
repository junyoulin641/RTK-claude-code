#!/bin/bash

# List all epics across all projects

echo "Getting epics..."
echo ""
echo ""

if [ ! -d "./doc" ]; then
  echo "📁 No projects directory found. Create your first project with: /pm:project-new <project_name>"
  exit 0
fi

# Check if any projects exist
project_count=$(ls -d ./doc/*/ 2>/dev/null | wc -l)
if [ "$project_count" -eq 0 ]; then
  echo "📁 No projects found. Create your first project with: /pm:project-new <project_name>"
  exit 0
fi

echo "📚 All Epics by Project"
echo "======================="
echo ""

total_epics=0
total_tasks=0

# Process all projects
for project_dir in ./doc/*/; do
  [ -d "$project_dir" ] || continue
  
  project_name=$(basename "$project_dir")
  epics_dir="$project_dir/epics"
  
  [ -d "$epics_dir" ] || continue
  
  # Check if any epic files exist in this project
  epic_file_count=$(ls "$epics_dir"/*/*.md 2>/dev/null | wc -l)
  [ "$epic_file_count" -eq 0 ] && continue
  
  echo "📦 Project: $project_name"
  echo "   ────────────────────────"
  
  # Initialize arrays for this project
  planning_epics=""
  in_progress_epics=""
  completed_epics=""
  
  # Process all features and their epics
  for feature_dir in "$epics_dir"/*/; do
    [ -d "$feature_dir" ] || continue
    
    feature_name=$(basename "$feature_dir")
    
    # Process all epic files in this feature
    for epic_file in "$feature_dir"epic-*.md; do
      [ -f "$epic_file" ] || continue
      
      # Extract metadata
      epic_name=$(basename "$epic_file" .md)
      s=$(grep "^status:" "$epic_file" | head -1 | sed 's/^status: *//' | tr '[:upper:]' '[:lower:]')
      p=$(grep "^progress:" "$epic_file" | head -1 | sed 's/^progress: *//')
      g=$(grep "^github:" "$epic_file" | head -1 | sed 's/^github: *//')
      
      # Defaults
      [ -z "$p" ] && p="0%"
      
      # Count tasks in the epic directory
      epic_task_dir="$feature_dir$epic_name"
      if [ -d "$epic_task_dir" ]; then
        t=$(ls "$epic_task_dir"/[0-9]*.md 2>/dev/null | wc -l)
      else
        t=0
      fi
      
      # Format output
      if [ -n "$g" ]; then
        i=$(echo "$g" | grep -o '/[0-9]*$' | tr -d '/')
        entry="    📋 $epic_name (#$i) - $p complete ($t tasks)"
      else
        entry="    📋 $epic_name - $p complete ($t tasks)"
      fi
      
      # Add feature info if displaying
      entry="$entry (Feature: $feature_name)"
      
      # Categorize by status
      case "$s" in
        planning|draft|"")
          planning_epics="${planning_epics}${entry}\n"
          ;;
        in-progress|in_progress|active|started)
          in_progress_epics="${in_progress_epics}${entry}\n"
          ;;
        completed|complete|done|closed|finished)
          completed_epics="${completed_epics}${entry}\n"
          ;;
        *)
          planning_epics="${planning_epics}${entry}\n"
          ;;
      esac
      
      ((total_epics++))
      ((total_tasks += t))
    done
  done
  
  # Display for this project
  echo "   🔍 Planning:"
  if [ -n "$planning_epics" ]; then
    echo -e "$planning_epics" | sed '/^$/d'
  else
    echo "      (none)"
  fi
  
  echo "   🚀 In Progress:"
  if [ -n "$in_progress_epics" ]; then
    echo -e "$in_progress_epics" | sed '/^$/d'
  else
    echo "      (none)"
  fi
  
  echo "   ✅ Completed:"
  if [ -n "$completed_epics" ]; then
    echo -e "$completed_epics" | sed '/^$/d'
  else
    echo "      (none)"
  fi
  
  echo ""
done

# Summary
echo "📊 Summary"
echo "   Total projects: $project_count"
echo "   Total epics: $total_epics"
echo "   Total tasks: $total_tasks"

exit 0