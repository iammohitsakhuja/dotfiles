---
argument-hint: <filename>
description: "Comprehensive shellcheck analysis and fixing workflow. Usage: /shellcheck-fix <filename>"
author: "Mohit Sakhuja"
version: "2.0"
---

# Shellcheck Fix Command

Comprehensive shellcheck analysis and fixing workflow that:

1. Applies automatic fixes first
2. Analyzes remaining issues
3. Prioritizes issues by severity
4. Creates an improvement plan
5. Implements fixes with user approval

## Instructions

Perform comprehensive shellcheck analysis and fixing workflow for the shell script `$ARGUMENTS`.

Execute the following steps in order:

**Step 1: Apply automatic shellcheck fixes**

!if [ ! -f "$ARGUMENTS" ]; then echo "❌ Error: File '$ARGUMENTS' not found"; exit 1; fi; echo "🔧 Applying automatic shellcheck fixes to $ARGUMENTS..."; shellcheck -f diff "$ARGUMENTS" > "$ARGUMENTS.patch" 2>/dev/null; if [ -s "$ARGUMENTS.patch" ]; then patch "$ARGUMENTS" < "$ARGUMENTS.patch" && echo "✅ Applied automatic fixes to $ARGUMENTS"; else echo "ℹ️  No automatic fixes available for $ARGUMENTS"; fi; rm -f "$ARGUMENTS.patch"

**Step 2: Analyze remaining issues**

Read the file contents and run shellcheck to identify any remaining issues:

!echo "🔍 Running shellcheck analysis on $ARGUMENTS..."; shellcheck "$ARGUMENTS" 2>&1 || echo "Analysis complete - will categorize issues above"

Now read the file: @$ARGUMENTS

**Step 3: Prioritize and categorize issues**

Based on the shellcheck output and file contents, categorize the remaining issues by severity:

- **🔴 Critical**: Security vulnerabilities, potential data loss, script-breaking bugs
- **🟡 Important**: Best practices violations, maintainability issues, portability concerns
- **🟢 Minor**: Style preferences, minor optimizations, cosmetic improvements

**Step 4: Create improvement plan**

Think thoroughly about the remaining issues and create a prioritized plan that explains:

- What each issue means and why it matters
- The proposed fix for each issue
- The complexity and risk of each change
- Recommended order of implementation

Present this plan to the user for approval.

**Step 5: Implement approved fixes**

After receiving user approval, implement the fixes systematically following these principles:

- **Follow shell scripting best practices**: Use proper quoting, error handling, and POSIX compliance where applicable
- **Prioritize maintainable solutions over quick fixes**: Choose readable, robust implementations that will be easy to understand and modify in the future
- Work through one priority category at a time (Critical → Important → Minor)
- Make incremental changes to maintain script functionality
- Verify each fix doesn't introduce new issues
- Provide clear explanations of changes made and why they improve the code
