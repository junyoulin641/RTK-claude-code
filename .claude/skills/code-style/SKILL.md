---
name: royaltek-coding-standards
description: Apply RoyalTek coding standards with comprehensive function documentation, file headers with copyright, and three-part code structure. Respects each language's universal naming conventions (Python uses snake_case per PEP 8, JavaScript uses camelCase, etc.) while ensuring RoyalTek branding and documentation consistency. Use when creating or reviewing code for RoyalTek projects across Python, JavaScript, Java, C/C++, TypeScript, and other languages.
---

# RoyalTek Coding Standards

Apply RoyalTek's coding standards that combine language-specific best practices with company branding requirements.

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

Every file MUST start with this header. Use the appropriate comment style for your language:

### C/C++, Java, JavaScript, TypeScript
```c
/**************************************************
*      RoyalTek Company Limited                   *
*      Copyright [YYYY] RoyalTek Co., Ltd.        *
*      All Rights Reserved                        *
***************************************************
File Name: [filename]
Author: [author name]
Date: [YYYY/MM/DD]
Description:
    [Brief description of file purpose]
Notes:
    [Dependencies or special notes]
***************************************************/
```

### Python
```python
"""
**************************************************
*      RoyalTek Company Limited                  *
*      Copyright 2024 RoyalTek Co., Ltd.         *
*      All Rights Reserved                       *
**************************************************
File Name: [filename].py
Author: [author name]
Date: [YYYY/MM/DD]
Description:
    [Brief description of file purpose]
Notes:
    [Dependencies or special notes]
**************************************************
"""
```

## Required Function Documentation

Every function MUST have this documentation format. Use the appropriate comment style:

### C/C++, Java, JavaScript, TypeScript
```c
/************************************************
Function Name: functionName
Author: [author name]
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
    [usage example]
************************************************/
```

### Python
```python
################################################
# Function Name: function_name
# Author: [author name]
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
#     [usage example]
################################################
```

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

## Company Branding

For documents requiring company branding:
```bash
# Add logo to documents
python scripts/addCompanyBranding.py <input> <output>
```

## Important Notes

1. **Language conventions respected** - Each language follows its community standards (PEP 8 for Python, etc.)
2. **RoyalTek elements mandatory** - File headers, function docs, and code structure always required
3. **Third-party code exempt** - Only apply to RoyalTek-authored code
4. **Quality over uniformity** - Better code through established best practices
