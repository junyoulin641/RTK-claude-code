#!/bin/bash

# List all PRDs across all projects

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

echo "Getting PRDs..."
echo ""
echo ""

echo "📋 All PRDs by Project"
echo "======================"
echo ""

total_prds=0
backlog_total=0
in_progress_total=0
implemented_total=0

# Process all projects
for project_dir in ./doc/*/; do
  [ -d "$project_dir" ] || continue
  
  project_name=$(basename "$project_dir")
  prds_dir="$project_dir/prds"
  
  [ -d "$prds_dir" ] || continue
  
  # Count PRDs in this project
  prd_count=$(ls "$prds_dir"/*.md 2>/dev/null | wc -l)
  [ "$prd_count" -eq 0 ] && continue
  
  echo "📦 Project: $project_name"
  echo "   ────────────────────────"
  
  # Initialize counters for this project
  backlog_count=0
  in_progress_count=0
  implemented_count=0
  
  # Helper function to get corresponding epic status
  get_epic_status() {
    local feature_name="$1"
    local epic_file="$project_dir/epics/$feature_name/epic.md"
    
    if [ -f "$epic_file" ]; then
      local epic_status=$(grep "^status:" "$epic_file" | head -1 | sed 's/^status: *//')
      local epic_progress=$(grep "^progress:" "$epic_file" | head -1 | sed 's/^progress: *//')
      [ -z "$epic_progress" ] && epic_progress="0%"
      echo " (Epic: $epic_status $epic_progress)"
    else
      echo " (No Epic)"
    fi
  }
  
  # Process all PRDs in this project
  echo "   🔍 Backlog PRDs:"
  for file in "$prds_dir"/*.md; do
    [ -f "$file" ] || continue
    status=$(grep "^status:" "$file" | head -1 | sed 's/^status: *//')
    if [ "$status" = "backlog" ] || [ "$status" = "draft" ] || [ -z "$status" ]; then
      name=$(grep "^name:" "$file" | head -1 | sed 's/^name: *//')
      desc=$(grep "^description:" "$file" | head -1 | sed 's/^description: *//')
      [ -z "$name" ] && name=$(basename "$file" .md)
      [ -z "$desc" ] && desc="No description"
      epic_info=$(get_epic_status "$name")
      echo "      📋 $name - $desc$epic_info"
      ((backlog_count++))
      ((backlog_total++))
    fi
  done
  [ $backlog_count -eq 0 ] && echo "      (none)"
  
  echo "   🔄 In-Progress PRDs:"
  for file in "$prds_dir"/*.md; do
    [ -f "$file" ] || continue
    status=$(grep "^status:" "$file" | head -1 | sed 's/^status: *//')
    if [ "$status" = "in-progress" ] || [ "$status" = "active" ]; then
      name=$(grep "^name:" "$file" | head -1 | sed 's/^name: *//')
      desc=$(grep "^description:" "$file" | head -1 | sed 's/^description: *//')
      [ -z "$name" ] && name=$(basename "$file" .md)
      [ -z "$desc" ] && desc="No description"
      epic_info=$(get_epic_status "$name")
      echo "      📋 $name - $desc$epic_info"
      ((in_progress_count++))
      ((in_progress_total++))
    fi
  done
  [ $in_progress_count -eq 0 ] && echo "      (none)"
  
  echo "   ✅ Implemented PRDs:"
  for file in "$prds_dir"/*.md; do
    [ -f "$file" ] || continue
    status=$(grep "^status:" "$file" | head -1 | sed 's/^status: *//')
    if [ "$status" = "implemented" ] || [ "$status" = "completed" ] || [ "$status" = "done" ]; then
      name=$(grep "^name:" "$file" | head -1 | sed 's/^name: *//')
      desc=$(grep "^description:" "$file" | head -1 | sed 's/^description: *//')
      [ -z "$name" ] && name=$(basename "$file" .md)
      [ -z "$desc" ] && desc="No description"
      epic_info=$(get_epic_status "$name")
      echo "      📋 $name - $desc$epic_info"
      ((implemented_count++))
      ((implemented_total++))
    fi
  done
  [ $implemented_count -eq 0 ] && echo "      (none)"
  
  echo ""
  ((total_prds += backlog_count + in_progress_count + implemented_count))
done

# Display summary
echo "📊 PRD Summary"
echo "   Total projects: $project_count"
echo "   Total PRDs: $total_prds"
echo "   Backlog: $backlog_total"
echo "   In-Progress: $in_progress_total"
echo "   Implemented: $implemented_total"

exit 0