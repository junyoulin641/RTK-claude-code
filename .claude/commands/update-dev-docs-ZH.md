---
name: update-dev-docs
description: "更新并保存所有进度到 tasks.md。执行完整验证并生成会话报告。可随时执行以更新进度。"
---

## /update-dev-docs 命令

**目的**：更新并保存所有进度到 tasks.md，执行完整验证

**执行时机**：任何时刻都可以执行（建议在开始新会话前执行）

**功能**：
- 扫描当前会话中的所有编辑文件
- 执行完整的编辑验证
- 用详细信息更新 tasks.md
- 计算最终进度百分比
- 生成详细的会话报告
- 准备无缝继续工作

---

## 执行逻辑

### 步骤 1：扫描所有编辑的文件

我会检查这个会话期间编辑的所有文件：

```bash
# 从 Git 状态或文件修改时间扫描
git status --short  # 如果有 Git 仓库
find . -type f -mmin -120  # 最后 2 小时修改的文件
```

我会检测：
- 编辑的文件
- 行数变化
- 文件类型和语言
- 编辑时间戳

### 步骤 2：确认项目位置

我会定位 tasks.md 文件：

```bash
find dev/active -name "tasks.md" -type f
```

优先级顺序：
1. `dev/active/[project-name]/tasks.md`
2. `dev/active/tasks.md`
3. `dev/tasks.md`
4. 当前目录 `tasks.md`

### 步骤 3：执行完整验证和更新

与 PostToolUse Hook 的轻量级更新不同，`/update-dev-docs` 执行：

**1. 完整验证**
- 检查所有编辑文件内容
- 验证文件完整性
- 根据项目要求验证

**2. 精确匹配**
- 将文件与 tasks.md 中的任务精确匹配
- 确定每个文件属于哪些任务
- 计算任务完成率

**3. 详细更新**
- 更新文件信息（行数、语言、时间戳）
- 标记所有编辑文件为已完成
- 更新子任务状态
- 计算完成百分比

**4. 进度计算**
- 计算已完成的文件/任务数
- 计算总体进度百分比
- 多个级别追踪进度（文件、任务、阶段）

**5. 决策记录**
- 记录会话期间做出的所有决策
- 记录架构选择
- 记录遇到的任何挑战

### 步骤 4：生成完整的会话报告

追加到 tasks.md：

```markdown
====================================
会话完成报告 [YYYY-MM-DD HH:MM:SS]
====================================

进度摘要：
  • 当前进度：50%（5/10 任务）
  • 已完成任务：
    - 任务 1.1：设置（100%）
    - 任务 1.2：认证系统（90%）
  • 待完成任务：
    - 任务 1.3：数据库层（0%）

编辑的文件：
  ✅ auth.py（150 行）
  ✅ config.py（50 行）
  ✅ tests.py（80 行）

下次会话开始位置：
  → 任务 1.3：实现数据库层

重要决策：
  • 使用 PostgreSQL 而非 MongoDB
  • 实现 ORM 层而非原始 SQL

注意事项：
  • auth.py 的密码哈希函数需要添加盐值
  • 需要添加更多单元测试覆盖
  • 考虑添加 API 文档

====================================
```

### 步骤 5：显示摘要并准备新会话

输出清晰的摘要：

```
✅ /update-dev-docs 执行完成

📊 进度摘要：
  • 进度：50%（5/10 任务）
  • 完成的文件：3 个
  • 新增总行数：280 行

📝 编辑的文件：
  ✅ auth.py（150 行）
  ✅ config.py（50 行）
  ✅ tests.py（80 行）

🎯 下一个任务：
  → 任务 1.3：实现数据库层

⏳ 准备就绪！
   执行 'continue' 命令开始新会话
```

---

## 详细实现步骤

### 步骤 1：扫描和计数

```
扫描编辑的文件：
  • 如果是 Git 仓库，使用 git status
  • 否则使用 find 查找文件修改时间
  • 计数编辑文件和总行数新增
```

### 步骤 2：定位 tasks.md

```
搜索层级：
  1. dev/active/[project-name]/tasks.md
  2. dev/active/tasks.md
  3. dev/tasks.md
  4. 当前目录 tasks.md

如果找不到，报告错误并停止
```

### 步骤 3：完整验证

```
对于每个编辑的文件：
  1. 在 tasks.md 中找到对应的任务
  2. 验证文件名和路径匹配
  3. 获取详细的文件信息
  4. 确定完成状态
  5. 记录所有元数据
```

### 步骤 4：更新 tasks.md

```
更新操作：
  • 将所有编辑的文件标记为 [x]
  • 添加完成时间戳
  • 计算子任务完成比例
  • 计算整体进度百分比
  • 添加包含完整详情的会话报告
```

### 步骤 5：生成会话报告

```
报告包括：
  ✅ 执行时间戳
  ✅ 进度百分比
  ✅ 已完成任务列表
  ✅ 编辑的文件列表和行数
  ✅ 下次应开始的任务
  ✅ 做出的重要决策
  ✅ 实现注记
  ✅ 遇到的挑战
```

### 步骤 6：显示最终摘要

```
告知用户：
  ✅ 所有进度已保存
  ✅ tasks.md 已更新
  ✅ 会话报告已添加
  ✅ 准备好执行 'continue'
```

---

## 使用示例

### 执行 /update-dev-docs 时

**你执行**：
```
/update-dev-docs
```

**我回应**：
```
🔄 执行 /update-dev-docs 中...

步骤 1：扫描编辑的文件...
  ✅ 检测到 3 个编辑
     • auth.py
     • config.py
     • tests.py

步骤 2：定位任务文件...
  ✅ 找到：dev/active/my-project/tasks.md

步骤 3：完整验证...
  ✅ auth.py → 任务 1.2：认证系统
  ✅ config.py → 任务 1.1：设置
  ✅ tests.py → 任务 1.2：认证系统

步骤 4：更新进度...
  ✅ 标记文件为已完成
  ✅ 计算进度：50%
  ✅ 添加会话报告

✅ /update-dev-docs 执行完成

📊 进度摘要：
  • 进度：50%（5/10 任务）
  • 完成的文件：3 个
  • 新增总行数：280 行

🎯 下一个任务：
  → 任务 1.3：实现数据库层

⏳ 准备就绪！
   执行 'continue' 命令开始新会话
```

**你执行**：
```
continue
```

**我回应**：
```
Claude：自动加载所有文档...

✅ 文档已加载：
  • plan.md ✅
  • context.md ✅
  • tasks.md ✅

📊 进度已恢复：
  • 当前进度：50%（5/10 任务）
  • 已完成：任务 1.1, 任务 1.2
  • 待完成：任务 1.3 ~ 任务 1.10

🎯 下一个任务：
  → 任务 1.3：实现数据库层

⏳ 新上下文容量：100%

开始实现任务 1.3...
```

---

## 完整实现

### 伪代码

```
function update_dev_docs():
    # 步骤 1：扫描
    edited_files = scan_edited_files()
    
    # 步骤 2：定位
    tasks_file = find_tasks_file()
    if not tasks_file:
        print "❌ 无法找到 tasks.md"
        return
    
    # 步骤 3：验证
    for each file in edited_files:
        matching_task = find_matching_task(file, tasks_file)
        verify_file_content(file)
        get_file_info(file)  # 行数、语言等
    
    # 步骤 4：更新
    for each file in edited_files:
        update_task_status(file, tasks_file, "已完成")
        add_completion_time(file, tasks_file)
    
    # 步骤 5：计算
    completed = count_completed_tasks(tasks_file)
    total = count_all_tasks(tasks_file)
    progress = (completed / total) * 100
    
    # 步骤 6：报告
    add_session_report(tasks_file, {
        timestamp: current_time,
        progress: progress,
        completed_files: edited_files,
        next_task: find_next_incomplete_task(tasks_file),
        decisions: [],
        notes: []
    })
    
    # 步骤 7：摘要
    print_summary(edited_files, progress)
    print "准备好执行 'continue'"
```

---

## 与 PostToolUse Hook 的关键区别

| 项目 | PostToolUse Hook | /update-dev-docs |
|------|-----------------|-----------------|
| **触发** | 每个文件编辑后 | 用户执行命令 |
| **频率** | 频繁（每个文件） | 需要时执行一次 |
| **验证** | 轻量级 | 完整 |
| **详细程度** | 基本（文件名、时间） | 详细（所有元数据） |
| **性能开销** | 低 | 中等 |
| **准确度** | 中等 | 高 |
| **何时使用** | 持续追踪 | 会话完成时 |
| **是否必需** | 否（自动） | 是（手动） |

---

## /update-dev-docs 执行的检查清单

执行 /update-dev-docs 时验证：

- [ ] 检测到所有编辑的文件？
- [ ] 找到了 tasks.md 文件？
- [ ] 所有文件都匹配到正确的任务？
- [ ] 进度百分比计算正确？
- [ ] 会话报告已添加？
- [ ] 下一个任务清楚地指定了？
- [ ] 最终摘要显示无误？

---

## 常见问题解答

### Q：什么时候应该执行 /update-dev-docs？

A：任何时刻都可以执行，但最佳时刻是：
- 开始新会话前
- 上下文很高时（85%+）
- 完成一个重要任务后
- 想明确保存进度时

### Q：PostToolUse Hook 和 /update-dev-docs 有什么区别？

A：
- **Hook**：频繁运行、轻量级、持续追踪
- **/update-dev-docs**：每个会话运行一次、完整验证、详细报告

### Q：如果找不到 tasks.md 会怎样？

A：
- 命令会报告错误
- 不会执行自动更新
- 先用 /dev-docs 命令创建 tasks.md

### Q：我可以多次执行 /update-dev-docs 吗？

A：
- 可以，多次执行都没问题
- 每次执行都会更新进度
- 多个报告会被添加到 tasks.md

### Q：/update-dev-docs 会清理上下文吗？

A：
- 不会，它只更新 tasks.md
- 要清理上下文，执行 'continue' 开始新会话
- 上下文由 Claude Code 自动管理

---

## 下一步

执行 `/update-dev-docs` 后：

1. ✅ 检查 tasks.md 是否正确更新
2. ✅ 验证会话报告内容
3. ✅ 确认下一个任务清楚指定
4. ✅ 执行 'continue' 开始新会话
5. ✅ 新会话自动加载所有文档
6. ✅ 无缝恢复进度并继续工作

---
