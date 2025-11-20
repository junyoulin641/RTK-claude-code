#!/bin/bash

#######################################
# PostToolUse Hook - 进度追踪器
#
# 触发时机：每次 Claude 编辑文件后自动触发
# 功能：实时更新 tasks.md 的进度
#
# 特性：
#   • 检测编辑的文件
#   • 更新 tasks.md 的完成状态
#   • 计算进度百分比
#   • 根据上下文使用率自动降级
#   • 彩色终端输出
#######################################

# 终端输出颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# =====================================
# 函数：估算上下文使用率百分比
# =====================================

estimate_context_usage() {
    local message_count=0
    
    # 方法 1：计算对话日志的行数
    if [ -f "conversation.log" ]; then
        message_count=$(wc -l < conversation.log 2>/dev/null || echo 0)
    fi
    
    # 方法 2：如果无法计算，从项目文件大小估算
    if [ $message_count -eq 0 ]; then
        local total_size=0
        for file in $(find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | head -20); do
            size=$(wc -c < "$file" 2>/dev/null || echo 0)
            total_size=$((total_size + size))
        done
        # 转换为估算消息数（大约 500 字节一行）
        message_count=$((total_size / 500))
    fi
    
    # 转换为百分比（基于估算）
    local percent=30
    if [ $message_count -gt 50 ]; then percent=50; fi
    if [ $message_count -gt 100 ]; then percent=70; fi
    if [ $message_count -gt 150 ]; then percent=85; fi
    if [ $message_count -gt 200 ]; then percent=95; fi
    
    echo $percent
}

# =====================================
# 函数：获取编辑的文件
# =====================================

get_edited_files() {
    # 方法 1：尝试从 Git 状态获取
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        git status --short | grep -E '^ M| M ' | awk '{print $NF}'
    else
        # 方法 2：查找最近 5 分钟内修改的文件
        find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.cpp" \) \
            -mmin -5 ! -path "./node_modules/*" ! -path "./.git/*" ! -path "./dev/*" 2>/dev/null | head -20
    fi
}

# =====================================
# 函数：找到 tasks.md 文件
# =====================================

find_tasks_file() {
    # 优先级顺序：
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
# 函数：在 tasks.md 中找到匹配的任务
# =====================================

find_matching_task() {
    local filename="$1"
    local tasks_file="$2"
    
    # 在 tasks.md 中搜索包含此文件名的任务
    grep -B 3 "$filename" "$tasks_file" 2>/dev/null | grep "###\|##\|Task" | tail -1 || echo ""
}

# =====================================
# 函数：更新任务文件（根据更新级别）
# =====================================

update_tasks_file() {
    local filename="$1"
    local tasks_file="$2"
    local update_level="$3"
    local timestamp="$4"
    
    # 如果 tasks.md 包含此文件，标记为已完成
    if grep -q "$filename" "$tasks_file" 2>/dev/null; then
        case "$update_level" in
            FULL|NORMAL)
                # 使用 sed 更新（如果文件名前有 [ ] 则改为 [x]）
                if command -v sed > /dev/null 2>&1; then
                    sed -i.bak "s/\- \[ \] $filename/- [x] $filename ($timestamp)/g" "$tasks_file" 2>/dev/null || true
                fi
                ;;
        esac
    else
        # 如果 tasks.md 不包含此文件，追加它
        case "$update_level" in
            FULL|NORMAL)
                echo "    - [x] $filename ($timestamp)" >> "$tasks_file"
                ;;
            LIGHT)
                echo "    - [x] $filename" >> "$tasks_file"
                ;;
            MINIMAL)
                echo "    - [ ] $filename (待验证)" >> "$tasks_file"
                ;;
        esac
    fi
}

# =====================================
# 函数：计算进度百分比
# =====================================

calculate_progress() {
    local tasks_file="$1"
    
    if [ ! -f "$tasks_file" ]; then
        echo "0"
        return
    fi
    
    local completed=0
    local total=0
    
    # 计算任务数
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
# 主程序
# =====================================

main() {
    # 设置工作目录
    PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-.}"
    cd "$PROJECT_ROOT" || exit 1
    
    # 输出开始信息
    echo -e "${BLUE}═════════════════════════════════════${NC}"
    echo -e "${BLUE}PostToolUse Hook - 进度追踪系统${NC}"
    echo -e "${BLUE}═════════════════════════════════════${NC}"
    
    # ========== 步骤 1：估算上下文使用率 ==========
    
    local CONTEXT_PERCENT=$(estimate_context_usage)
    
    echo -e "${YELLOW}步骤 1：估算上下文使用率${NC}"
    echo "  📊 估算上下文：$CONTEXT_PERCENT%"
    
    # 根据上下文确定执行级别
    local UPDATE_LEVEL="FULL"
    if [ $CONTEXT_PERCENT -lt 70 ]; then
        UPDATE_LEVEL="FULL"
        echo -e "  ${GREEN}🟢 执行级别：完整更新${NC}"
    elif [ $CONTEXT_PERCENT -lt 85 ]; then
        UPDATE_LEVEL="NORMAL"
        echo -e "  ${YELLOW}🟡 执行级别：正常更新${NC}"
    elif [ $CONTEXT_PERCENT -lt 95 ]; then
        UPDATE_LEVEL="LIGHT"
        echo -e "  ${ORANGE}🟠 执行级别：轻量级更新${NC}"
    else
        UPDATE_LEVEL="MINIMAL"
        echo -e "  ${RED}🔴 执行级别：最小化更新${NC}"
    fi
    
    # ========== 步骤 2：扫描编辑的文件 ==========
    
    echo -e ""
    echo -e "${YELLOW}步骤 2：扫描编辑的文件${NC}"
    
    local EDITED_FILES=$(get_edited_files)
    
    if [ -z "$EDITED_FILES" ]; then
        echo -e "  ${YELLOW}⚠️  未检测到编辑的文件${NC}"
        echo ""
        echo -e "${BLUE}Hook 执行完成（没有文件更新）${NC}"
        return 0
    fi
    
    local FILE_COUNT=$(echo "$EDITED_FILES" | wc -l)
    echo -e "  ${GREEN}✅ 检测到 $FILE_COUNT 个编辑${NC}"
    echo "$EDITED_FILES" | while read -r file; do
        [ -n "$file" ] && echo "     • $file"
    done
    
    # ========== 步骤 3：定位任务文件 ==========
    
    echo -e ""
    echo -e "${YELLOW}步骤 3：定位任务文件${NC}"
    
    local TASKS_FILE=$(find_tasks_file)
    
    if [ -z "$TASKS_FILE" ] || [ ! -f "$TASKS_FILE" ]; then
        echo -e "  ${YELLOW}⚠️  未找到 tasks.md，跳过更新${NC}"
        echo ""
        echo -e "${BLUE}Hook 执行完成（没有任务文件）${NC}"
        return 0
    fi
    
    echo -e "  ${GREEN}✅ 找到任务文件${NC}"
    echo "     $TASKS_FILE"
    
    # ========== 步骤 4：更新进度 ==========
    
    echo -e ""
    echo -e "${YELLOW}步骤 4：更新任务进度${NC}"
    
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
                echo -e "  ${ORANGE}⚠️  $filename (待验证)${NC}"
                ;;
        esac
    done
    
    # ========== 步骤 5：计算进度 ==========
    
    echo -e ""
    echo -e "${YELLOW}步骤 5：计算进度百分比${NC}"
    
    local PROGRESS=$(calculate_progress "$TASKS_FILE")
    
    echo -e "  ${GREEN}✅ 进度：$PROGRESS%${NC}"
    
    # 如果是完整或正常更新，更新进度记录
    if [ "$UPDATE_LEVEL" = "FULL" ] || [ "$UPDATE_LEVEL" = "NORMAL" ]; then
        echo "" >> "$TASKS_FILE"
        echo "---" >> "$TASKS_FILE"
        echo "**最后更新时间**：$TIMESTAMP" >> "$TASKS_FILE"
        echo "**当前进度**：$PROGRESS%" >> "$TASKS_FILE"
    fi
    
    # ========== 执行完成 ==========
    
    echo -e ""
    echo -e "${GREEN}✅ Hook 执行完成${NC}"
    echo -e ""
    echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║ 执行摘要${NC}"
    echo -e "${BLUE}╚════════════════════════════════════╝${NC}"
    echo "  • 检测文件：$FILE_COUNT 个"
    echo "  • 进度：$PROGRESS%"
    echo "  • 上下文：$CONTEXT_PERCENT%"
    echo "  • 更新级别：$UPDATE_LEVEL"
    
    # 如果上下文很高，提供警告
    if [ $CONTEXT_PERCENT -ge 85 ]; then
        echo -e ""
        echo -e "${RED}🔴 警告：上下文接近限制（$CONTEXT_PERCENT%）${NC}"
        echo -e "   ${YELLOW}考虑执行：/update-dev-docs${NC}"
    fi
    
    echo ""
}

# 执行主程序
main "$@"

exit 0
