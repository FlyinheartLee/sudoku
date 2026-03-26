---
name: superpowers
description: A complete software development workflow framework for coding agents. Includes brainstorming, TDD, systematic debugging, and subagent-driven development.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Exec
  - sessions_spawn
  - subagents
metadata:
  trigger: 当开始新项目、规划功能或需要软件开发方法论时触发
  author: Jesse Vincent (obra)
  source: https://github.com/obra/superpowers
  version: "1.0"
  note: 需要配合 superpowers-brainstorming, superpowers-tdd, superpowers-debugging, superpowers-subagent-dev 使用
---

# Superpowers - Software Development Framework

Superpowers is a complete software development workflow for coding agents, built on composable skills.

## Philosophy

- **Test-Driven Development** - Write tests first, always
- **Systematic over ad-hoc** - Process over guessing
- **Complexity reduction** - Simplicity as primary goal
- **Evidence over claims** - Verify before declaring success

## Workflow Overview

```
[Brainstorming]
      │
      ▼
[Design Spec Approved]
      │
      ▼
[Writing Plans]
      │
      ▼
[Subagent-Driven Development]
      │
      ▼
[Code Review]
      │
      ▼
[Complete]
```

## The Basic Workflow

1. **brainstorming** - Before writing code. Refines ideas through questions, explores alternatives, presents design for validation.

2. **test-driven-development** - During implementation. RED-GREEN-REFACTOR cycle.

3. **systematic-debugging** - When things go wrong. Four-phase root cause analysis.

4. **subagent-driven-development** - For parallel execution. Dispatches subagents per task with two-stage review.

## Available Skills

| Skill | Use When |
|-------|----------|
| superpowers-brainstorming | Starting a new feature or project |
| superpowers-tdd | Writing any code |
| superpowers-debugging | Debugging errors or bugs |
| superpowers-subagent-dev | Executing multi-task plans |

## Core Principles

### The Iron Law of TDD
```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

### The Iron Law of Debugging
```
NO FIXES WITHOUT ROOT CAUSE
```

### Design for Isolation
- Break systems into small units with one clear purpose
- Can someone understand a unit without reading its internals?
- Can you change internals without breaking consumers?

## Getting Started

Start any new project with:
```
Read ~/.openclaw/workspace/skills/superpowers-brainstorming/SKILL.md
```

Then follow the workflow through each skill.

## Source

- **Original:** https://github.com/obra/superpowers
- **Author:** Jesse Vincent (obra)
- **License:** MIT
