---
name: code-style
description: "Apply RoyalTek coding standards to specified files or directories. Supports Python, JavaScript, TypeScript, Java, C/C++. Adds file headers, function documentation, applies naming conventions, and formats code according to RoyalTek standards. Read .claude/skills/code-style/SKILL.md for complete documentation."
---

# Code Style Command

Apply RoyalTek coding standards to your codebase.

## Quick Start

```
/code-style [target] [options]
```

**Parameters:**
- `target`: file.py, src/, or . (required)
- `--auto-fix`: Apply changes automatically
- `--check-only`: Show issues without modifying
- `--language`: Force language detection
- `--verbose`: Detailed output

**Examples:**
```
/code-style src/ --auto-fix
/code-style main.py --check-only
/code-style . --auto-fix --verbose
```

## Documentation

**For complete details, see:**
- `.claude/skills/code-style/SKILL.md` - Full standards and format specifications
- `.claude/skills/code-style/references/python-standards.md` - Python specific
- `.claude/skills/code-style/references/javascript-standards.md` - JavaScript specific

## Important

When applying code style, this command will:
1. Read author from `.claude/settings.json` env.AUTHOR_NAME (Jim.lin)
2. Use CURRENT YEAR for copyright (auto-detected)
3. Use TODAY'S DATE for file date (auto-detected)
4. Follow EXACT format from SKILL.md

**Settings required:**
```json
{
  "env": {
    "AUTHOR_NAME": "Jim.lin",
    "COMPANY_NAME": "RoyalTek Company Limited",
    "AUTHOR_EMAIL": "Jim.lin@royaltek.com"
  }
}
```

## Next Steps

1. Run: `/code-style src/ --check-only` to see issues
2. Run: `/code-style src/ --auto-fix` to apply standards
3. Review changes and commit

See `.claude/skills/code-style/SKILL.md` for complete format requirements.
