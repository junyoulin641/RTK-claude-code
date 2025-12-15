#!/bin/bash

# Show all blocked tasks across all projects

echo "Getting tasks..."
echo ""
echo ""

echo " Blocked Tasks"
echo "================"
echo ""

found=0

if [ ! -d "./doc" ]; then
  echo " No projects directory found."
  exit 0
fi

# Process all projects
for project_dir in ./doc/*/; do
  [ -d "$project_dir" ] || continue
  
  project_name=$(basename "$project_dir")
  epics_dir="$project_dir/epics"
  
  [ -d "$epics_dir" ] || continue
  
  # Process all epics in this project
  for epic_dir in "$epics_dir"/*/; do
    [ -d "$epic_dir" ] || continue
    
    feature_name=$(basename "$epic_dir")
    
    # Process all tasks in this epic
    for task_file in "$epic_dir"/[0-9]*.md; do
      [ -f "$task_file" ] || continue
      
      # Check if task is open
      status=$(grep "^status:" "$task_file" | head -1 | sed 's/^status: *//')
      if [ "$status" != "open" ] && [ -n "$status" ]; then
        continue
      fi
      
      # Check for dependencies
      deps_line=$(grep "^depends_on:" "$task_file" | head -1)
      if [ -n "$deps_line" ]; then
        deps=$(echo "$deps_line" | sed 's/^depends_on: *//')
        deps=$(echo "$deps" | sed 's/^\[//' | sed 's/\]$//')
        deps=$(echo "$deps" | sed 's/,/ /g')
        # Trim whitespace
        deps=$(echo "$deps" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        [ -z "$deps" ] && deps=""
      else
        deps=""
      fi
      
      if [ -n "$deps" ] && [ "$deps" != "depends_on:" ]; then
        task_name=$(grep "^name:" "$task_file" | head -1 | sed 's/^name: *//')
        task_num=$(basename "$task_file" .md)
        
        echo " Task #$task_num - $task_name"
        echo "   Project: $project_name"
        echo "   Epic: $feature_name"
        echo "   Blocked by: [$deps]"
        
        # Check status of dependencies
        open_deps=""
        for dep in $deps; do
          dep_file="$epic_dir$dep.md"
          if [ -f "$dep_file" ]; then
            dep_status=$(grep "^status:" "$dep_file" | head -1 | sed 's/^status: *//')
            [ "$dep_status" = "open" ] && open_deps="$open_deps #$dep"
          fi
        done
        
        [ -n "$open_deps" ] && echo "   Waiting for:$open_deps"
        echo ""
        ((found++))
      fi
    done
  done
done

if [ $found -eq 0 ]; then
  echo "No blocked tasks found!"
  echo ""
  echo " All tasks with dependencies are either completed or in progress."
else
  echo " Total blocked: $found tasks"
fi

exit 0