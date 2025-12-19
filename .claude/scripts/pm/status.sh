#!/bin/bash

echo "Getting status..."
echo ""
echo ""


echo "📊 Project Status"
echo "================"
echo ""

echo "📄 PRDs:"
prd_total=0
if [ -d ".claude/prds" ]; then
  prd_total=$(ls .claude/prds/*.md 2>/dev/null | wc -l)
elif [ -d "./doc" ]; then
  prd_total=$(find ./doc -path "*/prds/*.md" 2>/dev/null | wc -l)
fi
if [ $prd_total -gt 0 ]; then
  echo "  Total: $prd_total"
else
  echo "  No PRDs found"
fi

echo ""
echo "📚 Epics:"
epic_total=0
if [ -d ".claude/epics" ]; then
  epic_total=$(ls -d .claude/epics/*/ 2>/dev/null | wc -l)
elif [ -d "./doc" ]; then
  epic_total=$(find ./doc -path "*/epics/*" -type d -mindepth 3 -maxdepth 3 2>/dev/null | wc -l)
fi
if [ $epic_total -gt 0 ]; then
  echo "  Total: $epic_total"
else
  echo "  No epics found"
fi

echo ""
echo "📝 Tasks:"
task_total=0
task_open=0
task_closed=0
if [ -d ".claude/epics" ]; then
  task_total=$(find .claude/epics -name "[0-9]*.md" 2>/dev/null | wc -l)
  task_open=$(find .claude/epics -name "[0-9]*.md" -exec grep -l "^status: *open" {} \; 2>/dev/null | wc -l)
  task_closed=$(find .claude/epics -name "[0-9]*.md" -exec grep -l "^status: *closed" {} \; 2>/dev/null | wc -l)
elif [ -d "./doc" ]; then
  task_total=$(find ./doc -path "*/epics/*/*/[0-9]*.md" 2>/dev/null | wc -l)
  task_open=$(find ./doc -path "*/epics/*/*/[0-9]*.md" -exec grep -l "^status: *open" {} \; 2>/dev/null | wc -l)
  task_closed=$(find ./doc -path "*/epics/*/*/[0-9]*.md" -exec grep -l "^status: *closed" {} \; 2>/dev/null | wc -l)
fi
if [ $task_total -gt 0 ]; then
  echo "  Open: $task_open"
  echo "  Closed: $task_closed"
  echo "  Total: $task_total"
else
  echo "  No tasks found"
fi

exit 0
