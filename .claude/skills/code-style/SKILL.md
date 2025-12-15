---
name: royaltek-coding-standards
description: Apply RoyalTek coding standards with comprehensive function documentation, file headers with copyright, and three-part code structure. Respects each language's universal naming conventions (Python uses snake_case per PEP 8, JavaScript uses camelCase, etc.) while ensuring RoyalTek branding and documentation consistency. Use when creating or reviewing code for RoyalTek projects across Python, JavaScript, Java, C/C++, TypeScript, and other languages.
---

# RoyalTek Coding Standards

Apply RoyalTek's coding standards that combine language-specific best practices with company branding requirements.

## ⚙️ Configuration from settings.json

**CRITICAL: Author name MUST be read from `.claude/settings.json` environment variables:**

```json
{
  "env": {
    "AUTHOR_NAME": "Jim.lin",
    "COMPANY_NAME": "RoyalTek Company Limited",
    "AUTHOR_EMAIL": "Jim.lin@royaltek.com"
  }
}
```

**Rules for ALL code generation:**
1. Always use the EXACT format shown below
2. Do NOT create custom formats
3. Do NOT add extra spacing or different layouts
4. Do NOT use alternative header styles
5. Use author from settings.json (Jim.lin)
6. Use CURRENT YEAR for copyright (NOT hardcoded 2024)
7. Use CURRENT DATE for file date (NOT a placeholder)

---

## Core Principles

**Respect language conventions** - Each language follows its established community standards (Python: PEP 8, JavaScript: Airbnb/Standard, etc.)

**RoyalTek essentials** - All code must include: copyright headers, comprehensive function documentation, and three-part code structure.

## Naming Conventions

### Follow Language-Specific Standards

Each language follows its established community conventions:

**Python** (PEP 8):
```python
user_name = "John"           Correct (snake_case)
get_user_data()             Correct (snake_case)

class UserAccount:          Correct (PascalCase)
MAX_CONNECTIONS = 100       Correct (UPPER_CASE)
```

**JavaScript/TypeScript** (Hungarian notation):
```javascript
let szUserName = "John"       Correct (Hungarian + camelCase)
let iUserAge = 25            Correct (Hungarian + camelCase)
let bIsActive = true         Correct (Hungarian + camelCase)

function getUserData(iUserId) {}   Correct

class UserAccount           Correct (PascalCase)
const MAX_CONNECTIONS = 100   Correct (UPPER_CASE)
```

**Java** (Hungarian notation):
```java
String szUserName = "John";    Correct (Hungarian + camelCase)
int iUserAge = 25;            Correct (Hungarian + camelCase)
boolean bIsActive = true;     Correct (Hungarian + camelCase)

public User getUserById(int iUserId) {}   Correct

class UserAccount            Correct (PascalCase)
final int MAX_CONNECTIONS = 100;   Correct (UPPER_CASE)
```

**C/C++** (Hungarian notation as per Code_Format_0_4.doc):
```cpp
int iCount;               Correct (Hungarian + camelCase)
char *szUserName;         Correct (Hungarian)

class CUserAccount        Correct (C prefix + PascalCase)
#define MAX_CONNECTIONS 100   Correct (UPPER_CASE)
```

### Hungarian Notation Type Prefixes

Used in JavaScript, TypeScript, Java, and C/C++:

| Type | Prefix | Example |
|------|--------|---------|
| string | sz | szUserName |
| int | i | iUserAge |
| long | l | lTimestamp |
| float | f | fPrice |
| double | d | dTotal |
| boolean | b | bIsActive |
| array/list | a | aItems |
| object/map | o/m | oUserData, mUserMap |
| function | fn | fnCallback |
| pointer | p | pData |
| Date | dt | dtCreatedDate |

## Required File Header

Every file MUST use EXACTLY this format. Do NOT deviate or customize.

### Python File Header - EXACT FORMAT

**This is the ONLY correct format for Python. Copy exactly as shown:**

```python
"""
**************************************************
*      RoyalTek Company Limited                  *
*      Copyright [CURRENT_YEAR] RoyalTek Co., Ltd.         *
*      All Rights Reserved                       *
**************************************************
File Name: [filename].py
Author: Jim.lin
Date: [YYYY/MM/DD]
Description:
    [Brief description of file purpose]
Notes:
    [Dependencies or special notes]
**************************************************
"""
```

**Important:**
- Replace `[CURRENT_YEAR]` with the current year (e.g., 2025 if today is 2025)
- Replace `[filename]` with actual filename (e.g., main.py)
- Replace `[YYYY/MM/DD]` with today's date (e.g., 2025/11/28)
- Author MUST be Jim.lin (from settings.json AUTHOR_NAME)

**INCORRECT examples to AVOID:**

❌ DO NOT use this format:
```python
"""
================================================================================
File Name    : main.py
Author       : Jim.lin
Date         : 2025/11/28
Company      : RoyalTek Company Limited
Description  : ...
================================================================================
"""
```

❌ DO NOT hardcode year (wrong):
```python
"""
*      Copyright 2024 RoyalTek Co., Ltd.  ← WRONG! Should be current year
"""
```

**Example of CORRECT Python header (today is 2025/11/28):**

```python
"""
**************************************************
*      RoyalTek Company Limited                  *
*      Copyright 2025 RoyalTek Co., Ltd.         *
*      All Rights Reserved                       *
**************************************************
File Name: main.py
Author: Jim.lin
Date: 2025/11/28
Description:
    Main CLI application module for RTK-AI-Kit.
    Provides command-line interface with start, info, and version commands.
Notes:
    Requires Click library for CLI functionality
**************************************************
"""
```

### C/C++, Java, JavaScript, TypeScript File Header - EXACT FORMAT

**This is the ONLY correct format. Copy exactly as shown:**

```c
/**************************************************
*      RoyalTek Company Limited                  *
*      Copyright [CURRENT_YEAR] RoyalTek Co., Ltd.         *
*      All Rights Reserved                       *
***************************************************
File Name: [filename]
Author: Jim.lin
Date: [YYYY/MM/DD]
Description:
    [Brief description of file purpose]
Notes:
    [Dependencies or special notes]
***************************************************/
```

**Important:**
- Replace `[CURRENT_YEAR]` with the current year (e.g., 2025)
- Replace `[filename]` with actual filename (e.g., main.js)
- Replace `[YYYY/MM/DD]` with today's date (e.g., 2025/11/28)
- Author MUST be Jim.lin (from settings.json AUTHOR_NAME)

**Example of CORRECT JavaScript header (today is 2025/11/28):**

```javascript
/**************************************************
*      RoyalTek Company Limited                  *
*      Copyright 2025 RoyalTek Co., Ltd.         *
*      All Rights Reserved                       *
***************************************************
File Name: main.js
Author: Jim.lin
Date: 2025/11/28
Description:
    Main entry point for the application.
    Sets up CLI with command handlers.
Notes:
    Uses yargs for CLI argument parsing
***************************************************/
```

## Required Function Documentation

Every function MUST have this documentation format. Use the appropriate comment style.

### Python Function Documentation - EXACT FORMAT

```python
################################################
# Function Name: function_name
# Author: Jim.lin
# Date: [YYYY/MM/DD]
# Description:
#     [Detailed function description]
# Parameters:
#     param_name (type) - [parameter description]
#     param_name (type) - [parameter description]
# Return:
#     type - [return value description]
# Notes:
#     [Special considerations]
# Example:
#     result = function_name(arg1, arg2)
################################################
```

**Important:**
- Replace `[YYYY/MM/DD]` with current date (e.g., 2025/11/28)
- Author MUST be Jim.lin (from settings.json AUTHOR_NAME)

### C/C++, Java, JavaScript, TypeScript Function Documentation - EXACT FORMAT

```c
/************************************************
Function Name: functionName
Author: Jim.lin
Date: [YYYY/MM/DD]
Description:
    [Detailed function description]
Parameters:
    type paramName - [parameter description]
    type paramName - [parameter description]
Return:
    type - [return value description]
Notes:
    [Special considerations]
Example:
    result = functionName(arg1, arg2)
************************************************/
```

**Important:**
- Replace `[YYYY/MM/DD]` with current date (e.g., 2025/11/28)
- Author MUST be Jim.lin (from settings.json AUTHOR_NAME)

## Code Structure Pattern

All functions follow this three-part structure:

```
function exampleFunction(params) {
    // 1. Parameter validation
    if (!params) return false;
    
    // 2. Main logic
    const result = processData(params);
    
    // 3. Return result
    return result;
}
```

## Language-Specific Applications

### Python (Follow PEP 8)
Use `references/python-standards.md` for Python-specific implementation.
Key: Use snake_case for variables and functions, following PEP 8 conventions.

### JavaScript/TypeScript
Use `references/javascript-standards.md` for JS/TS implementation.
Key: Use Hungarian notation (type prefixes) with camelCase.

### C/C++
Use `references/cpp-standards.md` for C++ implementation.
Key: Follow Hungarian notation as specified in Code_Format_0_4.doc.

### Java
Use `references/java-standards.md` for Java implementation.
Key: Use Hungarian notation (type prefixes) with camelCase.

## Validation Scripts

Run validation on your code:
```bash
# Validate Python files
python scripts/validatePython.py <file.py>

# Validate JavaScript files
node scripts/validateJavaScript.js <file.js>

# Check all files in directory
python scripts/batchValidator.py <directory>
```

## Code Templates

Use templates from `assets/templates/` as starting points:
- `assets/templates/python_template.py`
- `assets/templates/javascript_template.js`
- `assets/templates/cpp_template.cpp`
- `assets/templates/java_template.java`

**These templates show the EXACT format to use. Copy them precisely.**

## Company Branding

For documents requiring company branding:
```bash
# Add logo to documents
python scripts/addCompanyBranding.py <input> <o>
```

## Important Notes

1. **File Header Format** - MUST match the exact format shown above. No custom layouts allowed.
2. **Author information** - Always use Jim.lin (from settings.json AUTHOR_NAME)
3. **Copyright year** - Use CURRENT YEAR (NOT hardcoded). Auto-detect from system date.
4. **File date** - Use TODAY'S DATE in YYYY/MM/DD format (auto-detect from system)
5. **Company name** - Always use RoyalTek Company Limited
6. **Asterisks and spacing** - Match the template exactly. Do NOT use equals signs (=) or other characters.
7. **Language conventions respected** - Each language follows its community standards (PEP 8 for Python, etc.)
8. **RoyalTek elements mandatory** - File headers, function docs, and code structure always required
9. **Third-party code exempt** - Only apply to RoyalTek-authored code
10. **Quality over uniformity** - Better code through established best practices
11. **STRICT COMPLIANCE** - When generating code, use EXACTLY the format shown in this document. Do not create alternative formats.

---

## Summary of Exact Formats

| Element | Python | JS/Java/C++ |
|---------|--------|------------|
| File header start | `"""` | `/**` |
| Border char | `*` (asterisk) | `*` (asterisk) |
| Border style | `**` lines | `**` lines |
| File header end | `"""` | `*/` |
| Function doc start | `#` | `/` |
| Function doc end | `#` | `/` |
| Copyright year | Current year (auto) | Current year (auto) |
| File date | Today's date (auto) | Today's date (auto) |
| Author | Jim.lin (from settings) | Jim.lin (from settings) |

**All use `*` and `**` for borders. NO equals signs, NO pipes, NO other characters.**
