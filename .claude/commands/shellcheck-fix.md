---
description: "Apply shellcheck fixes to a shell script file automatically"
author: "Mohit Sakhuja"
version: "1.0"
---

# Shellcheck Fix

Automatically applies shellcheck suggestions to fix shell script issues.

## Usage

```bash
/shellcheck-fix <filename>
```

## Examples

```bash
/shellcheck-fix macos/install.sh
/shellcheck-fix test/utils/vm-manager.sh
```

## What it does

1. Runs `shellcheck -f diff` to generate fixes
2. Applies the patch if fixes are available
3. Reports success or if no fixes were needed
4. Cleans up temporary files

!if [ ! -f "$ARGUMENTS" ]; then echo "Error: File '$ARGUMENTS' not found"; exit 1; fi; shellcheck -f diff "$ARGUMENTS" > "$ARGUMENTS.patch"; if [ -s "$ARGUMENTS.patch" ]; then patch "$ARGUMENTS" < "$ARGUMENTS.patch" && echo "✅ Applied shellcheck fixes to $ARGUMENTS"; else echo "ℹ️  No shellcheck fixes needed for $ARGUMENTS"; fi; rm -f "$ARGUMENTS.patch"
