---
name: superpowers-debugging
description: Use when debugging errors, investigating unexpected behavior, or fixing bugs. Follows systematic 4-phase root cause analysis.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Exec
metadata:
  trigger: 当调试错误、调查异常行为或修复 bug 时触发
  author: Jesse Vincent (obra)
  source: https://github.com/obra/superpowers
  version: "1.0"
---

# Superpowers - Systematic Debugging

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE
```

Don't treat symptoms. Find the root cause and fix that.

## Four-Phase Process

### 1. INVESTIGATE - Gather Evidence

- What happened? (symptoms)
- When did it start?
- What changed recently?
- What are the error messages?
- Can you reproduce it consistently?

### 2. ANALYZE - Form Hypotheses

- What could cause these symptoms?
- List all possibilities
- Which is most likely?
- What would prove/disprove each hypothesis?

### 3. HYPOTHESIZE - Narrow Down

- Test one hypothesis at a time
- Create minimal reproduction case
- Use logging/tracing to confirm
- Don't change multiple things at once

### 4. IMPLEMENT - Fix Root Cause

- Fix the actual root cause, not symptoms
- Verify the fix resolves the issue
- Check for similar issues elsewhere
- Write a test to prevent regression

## Anti-Patterns

| Don't Do This | Do This Instead |
|---------------|-----------------|
| Change random things hoping it works | Form hypotheses, test systematically |
| Treat symptoms | Find root cause |
| Fix without understanding why | Investigate first, fix second |
| Skip reproduction | Create minimal reproduction case |

## Defense in Depth

After fixing:
1. Why did this bug happen?
2. How can we prevent similar bugs?
3. Can we add checks/tests to catch this earlier?

## Key Questions

- What is the simplest case that reproduces this?
- What would have to be true for this to happen?
- What have I assumed that might be wrong?
- What evidence would prove my hypothesis?
