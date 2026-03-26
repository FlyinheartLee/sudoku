---
name: superpowers-tdd
description: Use when implementing any feature, bugfix, or behavior change. Write tests first, watch them fail, then write minimal code to pass.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Exec
metadata:
  trigger: 当实现功能、修复 bug 或修改行为时触发
  author: Jesse Vincent (obra)
  source: https://github.com/obra/superpowers
  version: "1.0"
---

# Superpowers - Test-Driven Development (TDD)

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Write code before the test? **Delete it. Start over.**

## Red-Green-Refactor Cycle

1. **RED** - Write a failing test that describes the desired behavior
2. **GREEN** - Write minimal code to make the test pass
3. **REFACTOR** - Clean up the code while keeping tests green

## Why TDD Matters

- **If you didn't watch the test fail, you don't know if it tests the right thing**
- Tests define what the code SHOULD do, not what it DOES do
- Catches bugs before they reach production
- Creates a safety net for refactoring

## Rules

| Phase | Action |
|-------|--------|
| RED | Write ONE minimal test showing expected behavior |
| GREEN | Write MINIMAL code to pass (no more, no less) |
| REFACTOR | Clean code while tests stay green |

## Common Rationalizations (Don't Fall For These)

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests-after = "what does this do?" Tests-first = "what should this do?" |
| "This is different because..." | It's not. Write the test first. |

## Red Flags - STOP and Start Over

- Code before test
- "I already manually tested it"
- "Tests after achieve the same purpose"

**All of these mean: Delete code. Start over with TDD.**
