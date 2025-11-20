#!/bin/bash

#######################################
# PostToolUse Hook - Progress Tracker
#
# Trigger: Automatically after Claude edits a file
# Function: Real-time update of tasks.md progress
#
# Features:
#   • Detect edited files
#   • Update tasks.md with completion status
#   • Calculate progress percentage
#   • Auto-degrade based on context usage
#   • Colorful terminal output
#######################################

# Color definitions for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =====================================
# Function: Estimate context usage percentage
# =====================================

estimate_context_usage() {
    local message_count=0
    
    # Method 1: Count lines in conversation log
    if [ -f "conversation.log" ]; then
        message_count=$(wc -l < conversation.log 2>/dev/null || echo 0)
    fi
    
    # Method 2: If can't calculate, estimate from project file size
    if [ $message_count -eq 0 ]; then
        local total_size=0
        for file in $(find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | head -20); do
            size=$(wc -c < "$file" 2>/dev/null || echo 0)
            total_size=$((total_size + size))
        done
        # Convert to estimated message count (approximately 500 bytes per line)
        message_count=$((total_size / 500))
    fi
    
    # Convert to percentage (based on estimation)
    local percent=30
    if [ $message_count -gt 50 ]; then percent=50; fi
    if [ $message_count -gt 100 ]; then percent=70; fi
    if [ $message_count -gt 150 ]; then percent=85; fi
    if [ $message_count -gt 200 ]; then percent=95; fi
    
    echo $percent
}

# =====================================
# Function: Get edited files
# =====================================

get_edited_files() {
    # Method 1: Try to get from Git status
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        git status --short | grep -E '^ M| M ' | awk '{print $NF}'
    else
        # Method 2: Find files modified in last 5 minutes
        find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.cpp" \) \
            -mmin -5 ! -path "./node_modules/*" ! -path "./.git/*" ! -path "./dev/*" 2>/dev/null | head -20
    fi
}

# =====================================
# Function: Find tasks.md file
# =====================================

find_tasks_file() {
    # Priority order:
    # 1. dev/active/[project]/tasks.md
    # 2. dev/tasks.md
    # 3. tasks.md
    
    if [ -f "dev/active/tasks.md" ]; then
        echo "dev/active/tasks.md"
    elif [ -d "dev/active" ]; then
        find dev/active -name "tasks.md" -type f | head -1
    elif [ -f "dev/tasks.md" ]; then
        echo "dev/tasks.md"
    elif [ -f "tasks.md" ]; then
        echo "tasks.md"
    else
        echo ""
    fi
}

# =====================================
# Function: Find matching task in tasks.md
# =====================================

find_matching_task() {
    local filename="$1"
    local tasks_file="$2"
    
    # Search for task containing this filename
    grep -B 3 "$filename" "$tasks_file" 2>/dev/null | grep "###\|##\|Task" | tail -1 || echo ""
}

# =====================================
# Function: Update task file (based on update level)
# =====================================

update_tasks_file() {
    local filename="$1"
    local tasks_file="$2"
    local update_level="$3"
    local timestamp="$4"
    
    # If tasks.md contains this file, mark as completed
    if grep -q "$filename" "$tasks_file" 2>/dev/null; then
        case "$update_level" in
            FULL|NORMAL)
                # Use sed to update (if file name preceded by [ ] change to [x])
                if command -v sed > /dev/null 2>&1; then
                    sed -i.bak "s/\- \[ \] $filename/- [x] $filename ($timestamp)/g" "$tasks_file" 2>/dev/null || true
                fi
                ;;
        esac
    else
        # If tasks.md doesn't contain this file, append it
        case "$update_level" in
            FULL|NORMAL)
                echo "    - [x] $filename ($timestamp)" >> "$tasks_file"
                ;;
            LIGHT)
                echo "    - [x] $filename" >> "$tasks_file"
                ;;
            MINIMAL)
                echo "    - [ ] $filename (pending verification)" >> "$tasks_file"
                ;;
        esac
    fi
}

# =====================================
# Function: Calculate progress percentage
# =====================================

calculate_progress() {
    local tasks_file="$1"
    
    if [ ! -f "$tasks_file" ]; then
        echo "0"
        return
    fi
    
    local completed=0
    local total=0
    
    # Count tasks
    if command -v grep > /dev/null 2>&1; then
        completed=$(grep -c "^\- \[x\]" "$tasks_file" 2>/dev/null || echo 0)
        total=$(grep -c "^\- \[" "$tasks_file" 2>/dev/null || echo 0)
    fi
    
    if [ $total -eq 0 ]; then
        echo "0"
    else
        echo $((completed * 100 / total))
    fi
}

# =====================================
# Main Program
# =====================================

main() {
    # Set working directory
    PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-.}"
    cd "$PROJECT_ROOT" || exit 1
    
    # Output start information
    echo -e "${BLUE}═════════════════════════════════════${NC}"
    echo -e "${BLUE}PostToolUse Hook - Progress Tracker${NC}"
    echo -e "${BLUE}═════════════════════════════════════${NC}"
    
    # ========== Step 1: Estimate context usage ==========
    
    local CONTEXT_PERCENT=$(estimate_context_usage)
    
    echo -e "${YELLOW}Step 1: Estimate Context Usage${NC}"
    echo "  📊 Estimated context: $CONTEXT_PERCENT%"
    
    # Determine execution level based on context
    local UPDATE_LEVEL="FULL"
    if [ $CONTEXT_PERCENT -lt 70 ]; then
        UPDATE_LEVEL="FULL"
        echo -e "  ${GREEN}🟢 Execution Level: Full Update${NC}"
    elif [ $CONTEXT_PERCENT -lt 85 ]; then
        UPDATE_LEVEL="NORMAL"
        echo -e "  ${YELLOW}🟡 Execution Level: Normal Update${NC}"
    elif [ $CONTEXT_PERCENT -lt 95 ]; then
        UPDATE_LEVEL="LIGHT"
        echo -e "  ${ORANGE}🟠 Execution Level: Light Update${NC}"
    else
        UPDATE_LEVEL="MINIMAL"
        echo -e "  ${RED}🔴 Execution Level: Minimal Update${NC}"
    fi
    
    # ========== Step 2: Scan edited files ==========
    
    echo -e ""
    echo -e "${YELLOW}Step 2: Scan Edited Files${NC}"
    
    local EDITED_FILES=$(get_edited_files)
    
    if [ -z "$EDITED_FILES" ]; then
        echo -e "  ${YELLOW}⚠️  No edited files detected${NC}"
        echo ""
        echo -e "${BLUE}Hook execution completed (no file updates)${NC}"
        return 0
    fi
    
    local FILE_COUNT=$(echo "$EDITED_FILES" | wc -l)
    echo -e "  ${GREEN}✅ Detected $FILE_COUNT edits${NC}"
    echo "$EDITED_FILES" | while read -r file; do
        [ -n "$file" ] && echo "     • $file"
    done
    
    # ========== Step 3: Locate tasks file ==========
    
    echo -e ""
    echo -e "${YELLOW}Step 3: Locate Tasks File${NC}"
    
    local TASKS_FILE=$(find_tasks_file)
    
    if [ -z "$TASKS_FILE" ] || [ ! -f "$TASKS_FILE" ]; then
        echo -e "  ${YELLOW}⚠️  tasks.md not found, skipping update${NC}"
        echo ""
        echo -e "${BLUE}Hook execution completed (no tasks file)${NC}"
        return 0
    fi
    
    echo -e "  ${GREEN}✅ Found tasks file${NC}"
    echo "     $TASKS_FILE"
    
    # ========== Step 4: Update progress ==========
    
    echo -e ""
    echo -e "${YELLOW}Step 4: Update Task Progress${NC}"
    
    local TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    local UPDATED_COUNT=0
    
    echo "$EDITED_FILES" | while read -r file; do
        if [ -z "$file" ]; then
            continue
        fi
        
        local filename=$(basename "$file")
        update_tasks_file "$filename" "$TASKS_FILE" "$UPDATE_LEVEL" "$TIMESTAMP"
        UPDATED_COUNT=$((UPDATED_COUNT + 1))
        
        case "$UPDATE_LEVEL" in
            FULL|NORMAL)
                echo -e "  ${GREEN}✅ $filename${NC}"
                ;;
            LIGHT)
                echo -e "  ${ORANGE}➕ $filename${NC}"
                ;;
            MINIMAL)
                echo -e "  ${ORANGE}⚠️  $filename (pending verification)${NC}"
                ;;
        esac
    done
    
    # ========== Step 5: Calculate progress ==========
    
    echo -e ""
    echo -e "${YELLOW}Step 5: Calculate Progress Percentage${NC}"
    
    local PROGRESS=$(calculate_progress "$TASKS_FILE")
    
    echo -e "  ${GREEN}✅ Progress: $PROGRESS%${NC}"
    
    # Update progress record if full or normal update
    if [ "$UPDATE_LEVEL" = "FULL" ] || [ "$UPDATE_LEVEL" = "NORMAL" ]; then
        echo "" >> "$TASKS_FILE"
        echo "---" >> "$TASKS_FILE"
        echo "**Last Updated**: $TIMESTAMP" >> "$TASKS_FILE"
        echo "**Current Progress**: $PROGRESS%" >> "$TASKS_FILE"
    fi
    
    # ========== Execution Complete ==========
    
    echo -e ""
    echo -e "${GREEN}✅ Hook execution completed${NC}"
    echo -e ""
    echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║ Execution Summary${NC}"
    echo -e "${BLUE}╚════════════════════════════════════╝${NC}"
    echo "  • Detected files: $FILE_COUNT"
    echo "  • Progress: $PROGRESS%"
    echo "  • Context: $CONTEXT_PERCENT%"
    echo "  • Update level: $UPDATE_LEVEL"
    
    # If context is high, provide warning
    if [ $CONTEXT_PERCENT -ge 85 ]; then
        echo -e ""
        echo -e "${RED}🔴 Warning: Context approaching limit ($CONTEXT_PERCENT%)${NC}"
        echo -e "   ${YELLOW}Consider executing: /update-dev-docs${NC}"
    fi
    
    echo ""
}

# Execute main program
main "$@"

exit 0
