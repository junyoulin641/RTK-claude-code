#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
################################################################################
# PostToolUse Hook - Progress Tracker (Python Version)
#
# Trigger: After Claude edits a file
# Function: Real-time update of tasks.md progress
#
# Features:
#   • Detect edited files
#   • Update tasks.md completion status
#   • Calculate progress percentage
#   • Auto-degrade based on context usage
#   • Colorful terminal output
################################################################################
"""

import os
import sys
import subprocess
import re
from datetime import datetime
from pathlib import Path
from typing import List, Tuple, Optional

# Color definitions for terminal output
class Colors:
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    RED = '\033[0;31m'
    ORANGE = '\033[0;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color


def estimate_context_usage() -> int:
    """Estimate context usage percentage."""
    context_percent = 30
    
    # Try to estimate from conversation log
    conv_log = Path("conversation.log")
    if conv_log.exists():
        try:
            with open(conv_log, 'r', encoding='utf-8') as f:
                lines = len(f.readlines())
            
            if lines > 200:
                context_percent = 95
            elif lines > 150:
                context_percent = 85
            elif lines > 100:
                context_percent = 70
            elif lines > 50:
                context_percent = 50
        except Exception:
            pass
    
    return context_percent


def get_edited_files() -> List[str]:
    """Get list of edited files."""
    files = []
    
    # Try to get from Git status
    try:
        if subprocess.run(['git', 'rev-parse', '--is-inside-work-tree'],
                         capture_output=True, timeout=5).returncode == 0:
            result = subprocess.run(
                ['git', 'status', '--short'],
                capture_output=True,
                text=True,
                timeout=5
            )
            for line in result.stdout.split('\n'):
                if line.strip().startswith(('M ', ' M')):
                    files.append(line.strip().split()[-1])
            return files
    except Exception:
        pass
    
    # Fallback: find recently modified files
    try:
        result = subprocess.run(
            ['find', '.', '-type', 'f', '-mmin', '-5',
             '(', '-name', '*.py', '-o', '-name', '*.js', '-o', '-name', '*.ts',
             '-o', '-name', '*.java', '-o', '-name', '*.cpp', ')',
             '!', '-path', './node_modules/*',
             '!', '-path', './.git/*',
             '!', '-path', './dev/*'],
            capture_output=True,
            text=True,
            timeout=5
        )
        files = [f.strip() for f in result.stdout.split('\n') if f.strip()][:20]
    except Exception:
        pass
    
    return files


def find_tasks_file() -> Optional[str]:
    """Find tasks.md file in standard locations."""
    paths_to_check = [
        'dev/active/tasks.md',
        'dev/tasks.md',
        'tasks.md',
    ]
    
    # Also check for project-specific tasks.md
    try:
        result = subprocess.run(
            ['find', 'dev/active', '-name', 'tasks.md', '-type', 'f'],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.stdout.strip():
            return result.stdout.strip().split('\n')[0]
    except Exception:
        pass
    
    for path in paths_to_check:
        if Path(path).exists():
            return path
    
    return None


def update_tasks_file(filename: str, tasks_file: str, update_level: str, timestamp: str) -> bool:
    """Update task file with completion status."""
    try:
        with open(tasks_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check if file is mentioned in tasks.md
        if filename in content:
            # Update status based on level
            if update_level in ['FULL', 'NORMAL']:
                # Replace [ ] with [x] for this file
                pattern = rf'- \[ \] {re.escape(filename)}'
                replacement = f'- [x] {filename} ({timestamp})'
                content = re.sub(pattern, replacement, content)
            
            with open(tasks_file, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        else:
            # Append file to tasks.md
            if update_level in ['FULL', 'NORMAL']:
                content += f"\n    - [x] {filename} ({timestamp})"
            elif update_level == 'LIGHT':
                content += f"\n    - [x] {filename}"
            else:  # MINIMAL
                content += f"\n    - [ ] {filename} (待驗證)"
            
            with open(tasks_file, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
    except Exception as e:
        print(f"Error updating tasks file: {e}")
        return False


def calculate_progress(tasks_file: str) -> int:
    """Calculate progress percentage from tasks.md."""
    try:
        with open(tasks_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        completed = len(re.findall(r'^\- \[x\]', content, re.MULTILINE))
        total = len(re.findall(r'^\- \[', content, re.MULTILINE))
        
        if total == 0:
            return 0
        
        return (completed * 100) // total
    except Exception:
        return 0


def print_section(title: str, color: str = Colors.BLUE) -> None:
    """Print a colored section header."""
    print(f"{color}{title}{Colors.NC}")


def print_item(text: str, status: str = '●') -> None:
    """Print an item with status."""
    print(f"  {status} {text}")


def main():
    """Main program."""
    # Set working directory
    project_root = os.environ.get('CLAUDE_PROJECT_DIR', '.')
    try:
        os.chdir(project_root)
    except Exception:
        pass
    
    # Output start information
    print_section("═══════════════════════════════════", Colors.BLUE)
    print_section("PostToolUse Hook - Progress Tracker", Colors.BLUE)
    print_section("═══════════════════════════════════", Colors.BLUE)
    print()
    
    # Step 1: Estimate context usage
    context_percent = estimate_context_usage()
    
    print_section("步驟 1：估算上下文使用率", Colors.YELLOW)
    print(f"  📊 估算上下文：{context_percent}%")
    
    # Determine execution level
    if context_percent < 70:
        update_level = "FULL"
        print_section("  🟢 執行級別：完整更新", Colors.GREEN)
    elif context_percent < 85:
        update_level = "NORMAL"
        print_section("  🟡 執行級別：正常更新", Colors.YELLOW)
    elif context_percent < 95:
        update_level = "LIGHT"
        print_section("  🟠 執行級別：輕量級更新", Colors.ORANGE)
    else:
        update_level = "MINIMAL"
        print_section("  🔴 執行級別：最小化更新", Colors.RED)
    
    print()
    
    # Step 2: Scan edited files
    print_section("步驟 2：掃描編輯的文件", Colors.YELLOW)
    
    edited_files = get_edited_files()
    
    if not edited_files:
        print_section("  ⚠️  未檢測到編輯的文件", Colors.YELLOW)
        print()
        print_section("Hook 執行完成（沒有文件更新）", Colors.BLUE)
        return 0
    
    file_count = len(edited_files)
    print_section(f"  ✅ 檢測到 {file_count} 個編輯", Colors.GREEN)
    for file in edited_files:
        print_item(file)
    
    print()
    
    # Step 3: Locate tasks file
    print_section("步驟 3：定位任務文件", Colors.YELLOW)
    
    tasks_file = find_tasks_file()
    
    if not tasks_file:
        print_section("  ⚠️  未找到 tasks.md，跳過更新", Colors.YELLOW)
        print()
        print_section("Hook 執行完成（沒有任務文件）", Colors.BLUE)
        return 0
    
    print_section("  ✅ 找到任務文件", Colors.GREEN)
    print_item(tasks_file)
    
    print()
    
    # Step 4: Update progress
    print_section("步驟 4：更新任務進度", Colors.YELLOW)
    
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    updated_count = 0
    
    for file in edited_files:
        filename = Path(file).name
        if update_tasks_file(filename, tasks_file, update_level, timestamp):
            updated_count += 1
            if update_level in ['FULL', 'NORMAL']:
                print_section(f"  ✅ {filename}", Colors.GREEN)
            elif update_level == 'LIGHT':
                print_section(f"  ➕ {filename}", Colors.ORANGE)
            else:
                print_section(f"  ⚠️  {filename} (待驗證)", Colors.ORANGE)
    
    print()
    
    # Step 5: Calculate progress
    print_section("步驟 5：計算進度百分比", Colors.YELLOW)
    
    progress = calculate_progress(tasks_file)
    
    print_section(f"  ✅ 進度：{progress}%", Colors.GREEN)
    
    # Update progress record
    if update_level in ['FULL', 'NORMAL']:
        try:
            with open(tasks_file, 'a', encoding='utf-8') as f:
                f.write(f"\n\n---\n")
                f.write(f"**最後更新時間**：{timestamp}\n")
                f.write(f"**當前進度**：{progress}%\n")
        except Exception:
            pass
    
    print()
    
    # Execution complete
    print_section("✅ Hook 執行完成", Colors.GREEN)
    print()
    print_section("╔════════════════════════════════════╗", Colors.BLUE)
    print_section("║ 執行摘要", Colors.BLUE)
    print_section("╚════════════════════════════════════╝", Colors.BLUE)
    print(f"  • 檢測文件：{file_count} 個")
    print(f"  • 進度：{progress}%")
    print(f"  • 上下文：{context_percent}%")
    print(f"  • 更新級別：{update_level}")
    
    # Warning if context is high
    if context_percent >= 85:
        print()
        print_section("🔴 警告：上下文接近限制（{}%）".format(context_percent), Colors.RED)
        print_section("   🎯 考慮執行：/update-dev-docs", Colors.YELLOW)
    
    print()
    
    return 0


if __name__ == '__main__':
    sys.exit(main())
