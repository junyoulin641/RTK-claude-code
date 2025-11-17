# Claude Code 配置說明

## ⚠️ 重要說明

**真正生效的配置**只有：
- `.claude/agents/code-reviewer.md` - Agent 描述已修改為強制性語言

**本文件僅供參考**，記錄了期望的程式碼審查流程。

---

本專案期望實作**強制性程式碼審查協議**，確保所有重要程式碼變更都經過自動審查。

## 配置檔案結構

```
.claude/
├── README.md                              # 本檔案
├── settings.local.json                    # 本地設定
├── agents/
│   └── code-reviewer.md                   # Code reviewer agent（已強化為強制性）
├── prompts/
│   ├── system.md                          # 系統提示補充（強制性工作流程）
│   └── code-review-protocol.md            # 詳細程式碼審查協議
└── skills/
    └── code-style/                        # RoyalTek 編碼標準 skill
        └── SKILL.md

## 已啟用的強制性規則

### 1. Code Reviewer Agent（強制性）

**位置**: `.claude/agents/code-reviewer.md`

**強制觸發條件**:
- 撰寫/修改 >100 行程式碼
- 任何安全敏感性程式碼（認證、檔案 I/O、資料庫等）
- 完成新功能實作
- 重大重構變更

**行為**: AUTOMATIC（自動），不等待使用者請求

### 2. Code Review Protocol（協議文件）

**位置**: `.claude/prompts/code-review-protocol.md`

**內容**:
- 詳細的決策樹
- 強制性工作流程步驟
- 正確/錯誤範例
- 完成前檢查清單
- 觸發條件對照表

### 3. System Prompt Additions（系統提示補充）

**位置**: `.claude/prompts/system.md`

**功能**:
- 增強標準編碼工作流程
- 加入強制性審查檢查點
- 明確的觸發條件
- 內部自我檢查範例

## 工作流程（MANDATORY）

```
1. 規劃任務
   ↓
2. 釐清需求
   ↓
3. 實作程式碼
   ↓
4. ⚠️ CHECKPOINT: 評估審查需求
   ├─ 符合條件？
   │  ├─ YES → 立即使用 code-reviewer agent
   │  │         ↓
   │  │       修復 CRITICAL/HIGH 問題
   │  │         ↓
   │  └─ NO  → 繼續
   ↓
5. 回報使用者（僅在審查完成後）
```

## 程式碼審查觸發條件

### 強制性（MANDATORY）

| 條件 | 程式碼行數 | 審查要求 |
|------|-----------|---------|
| 新功能/模組 | 任何 | ✅ 強制 |
| 安全敏感性程式碼 | 任何 | ✅ 強制 |
| 大型變更 | >100 | ✅ 強制 |
| 中型變更 | 50-100 | ✅ 強制 |
| 小型變更 | 20-50 | ⚠️ 建議 |
| 微小修復 | <20 | ⭕ 可選 |

### 安全敏感性程式碼定義

任何涉及以下的程式碼**必須**審查：
- 認證（登入、密碼、Token）
- 授權（權限、存取控制）
- 檔案操作（讀寫、上傳、下載）
- 網路操作（HTTP、API、Socket）
- 資料庫操作（查詢、ORM）
- 加密/解密
- 輸入驗證與清理
- Session 管理
- 環境變數/設定檔
- 命令執行

## 使用範例

### ✅ 正確範例

```
User: "請實作使用者認證功能"
Assistant: [規劃任務]
Assistant: [實作 auth.py - 250 行]
Assistant: 檢查點 - 我寫了 250 行安全敏感性程式碼
          → 強制審查
Assistant: [使用 code-reviewer agent]
Assistant: [修復 3 個 CRITICAL 安全問題]
Assistant: "已完成認證系統。在程式碼審查中，
           修復了密碼雜湊和 SQL 注入防護的安全問題。"
```

### ❌ 錯誤範例

```
User: "請實作使用者認證功能"
Assistant: [實作 auth.py - 250 行]
Assistant: "已完成認證系統！"
          ❌ 違反協議：未執行程式碼審查
```

## 配置檢查

確認配置已正確載入：

1. **檢查 agent 描述**:
   ```bash
   cat .claude/agents/code-reviewer.md
   ```
   應該看到 "**MANDATORY**" 字樣

2. **檢查協議文件**:
   ```bash
   cat .claude/prompts/code-review-protocol.md
   ```
   應該看到決策樹和檢查清單

3. **檢查系統提示**:
   ```bash
   cat .claude/prompts/system.md
   ```
   應該看到強制性工作流程

## 為什麼需要強制性審查？

1. **安全性**: 自動捕捉安全漏洞（SQL injection、XSS、路徑遍歷等）
2. **品質**: 發現潛在 bug 和邏輯錯誤
3. **一致性**: 確保程式碼符合專案標準
4. **學習**: 從審查建議中改進程式碼品質
5. **文件化**: 提供審查記錄作為品質保證

## 常見問題

### Q: 每次都要審查嗎？
A: 不是。只有符合觸發條件時才強制審查（>50 行或安全敏感性程式碼）

### Q: 我可以跳過審查嗎？
A: 不行。這是強制性協議，確保程式碼品質和安全性

### Q: 審查會很花時間嗎？
A: code-reviewer agent 通常在幾秒內完成，並能發現重要問題

### Q: 如果是簡單的修改呢？
A: <20 行的簡單修改可選擇性審查

## 維護

如需調整觸發條件，請編輯：
- `.claude/prompts/code-review-protocol.md` - 詳細協議
- `.claude/prompts/system.md` - 系統提示補充
- `.claude/agents/code-reviewer.md` - Agent 描述

## 參考資料

- [Code Review Protocol](.claude/prompts/code-review-protocol.md) - 完整協議文件
- [System Additions](.claude/prompts/system.md) - 系統提示補充
- [Code Reviewer Agent](.claude/agents/code-reviewer.md) - Agent 配置

---

**記住**: 程式碼審查是 **AUTOMATIC**（自動），**PROACTIVE**（主動），**MANDATORY**（強制性）
