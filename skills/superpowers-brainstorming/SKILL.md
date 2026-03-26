---
name: superpowers-brainstorming
description: Use when brainstorming ideas, designing features, or planning projects. Explores user intent and creates design specs before implementation.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Exec
metadata:
  trigger: 当需要头脑风暴、设计功能或规划项目时触发
  author: Jesse Vincent (obra)
  source: https://github.com/obra/superpowers
  version: "1.0"
---

# Superpowers - Brainstorming

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

## Core Principle

**Do NOT write any code until you have presented a design and the user has approved it.**

This applies to EVERY project regardless of perceived simplicity. "Simple" projects are where unexamined assumptions cause the most wasted work.

## Process

1. **Explore project context** — check files, docs, recent commits
2. **Ask clarifying questions** — one at a time, understand purpose/constraints/success criteria
3. **Propose 2-3 approaches** — with trade-offs and your recommendation
4. **Present design** — in sections scaled to their complexity, get user approval
5. **Write design doc** — save to appropriate location
6. **Transition to implementation**

## Anti-Pattern: "This Is Too Simple"

Every project goes through this process. A todo list, a single-function utility, a config change — all of them. The design can be short (a few sentences), but you MUST present it and get approval.

## Design for Isolation

Break the system into smaller units that each have one clear purpose:
- Can someone understand what a unit does without reading its internals?
- Can you change the internals without breaking consumers?
- Smaller, well-bounded units are easier to reason about

## Key Questions

- What are you trying to achieve?
- What constraints are you working within?
- What does success look like?
- Who are the users?
- What are the edge cases?

## Output

A written design spec that has been reviewed and approved by the user before any code is written.
