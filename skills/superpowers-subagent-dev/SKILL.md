---
name: superpowers-subagent-dev
description: Use when executing implementation plans with multiple independent tasks. Dispatches subagents for parallel work with two-stage review.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Exec
  - sessions_spawn
  - subagents
metadata:
  trigger: 当执行包含多个独立任务的实施计划时触发
  author: Jesse Vincent (obra)
  source: https://github.com/obra/superpowers
  version: "1.0"
---

# Superpowers - Subagent-Driven Development

## Overview

Use subagents for parallel task execution with systematic review. Scale your productivity by delegating to isolated agent instances.

## When to Use

- Implementation plan with multiple independent tasks
- Tasks can be worked on in parallel
- Need high-quality output with verification

## Workflow

```
Implementation Plan
       │
       ▼
[D dispatch subagent per task]
       │
       ▼
[Two-Stage Review]
  ├── Spec Compliance Review
  └── Code Quality Review
       │
       ▼
[Integrate & Continue]
```

## Task Dispatch

1. **Break into bite-sized tasks** (2-5 minutes each)
2. **Create isolated subagent** per task via `sessions_spawn`
3. **Provide clear context**: spec, files, expected output
4. **Set timeout** (default 5 minutes per task)

## Two-Stage Review

### Stage 1: Spec Compliance
- Does the output match the spec?
- Are all requirements met?
- Any missing functionality?

### Stage 2: Code Quality
- Is the code clean and maintainable?
- Are there tests?
- Any anti-patterns or issues?

**Critical issues block progress** - fix before continuing.

## Key Principles

| Principle | Why |
|-----------|-----|
| One task per subagent | Clear scope, easy to review |
| Fresh subagent per task | Clean context, no accumulated errors |
| Two-stage review | Catch both spec drift and quality issues |
| Parallel execution | Speed through independent work |

## Anti-Patterns

| Don't | Do |
|-------|-----|
| One subagent for all tasks | One subagent per task |
| Skip review | Always two-stage review |
| Ignore critical issues | Fix blockers immediately |
| Keep going with drift | Re-align with spec first |

## Monitoring

Use `subagents(action=list)` to track running tasks. Check status, intervene if stuck.

## Success Criteria

- All tasks complete
- All reviews pass
- Output matches spec
- Quality standards met
