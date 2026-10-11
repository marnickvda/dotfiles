---
name: pr-checklist
description:
  Use when creating or updating a pull request description (`gh pr create`, `gh pr edit`, rewriting a PR body).
---

# PR Checklist

## Overview

Do the quality checks yourself, silently. The PR description is for humans: short, plain, about what the change is and why. Proof of checks lives in CI and in your own verification, not in the PR body.

## Background checks (do all, do not write them into the PR)

1. Run the repo's real test and lint/format/typecheck commands. Fix failures before opening the PR.
2. Re-read the full diff as a stranger against:

| Principle | Check |
| --------- | ----- |
| DRY | No duplicated logic introduced. Repeated literals/shape are fine if abstracting would couple unrelated things. |
| KISS | Simple to read and maintain, not clever. |
| YAGNI | Every new abstraction has a current caller. |
| SOLID | Each changed unit has one clear responsibility. |
| Scope | Every line traces to the PR's stated problem. No drive-by edits. |
| Comments | Only non-obvious "why" remains. |

3. Violation found? Fix the code (or split the PR). Don't explain it in the description.

## Writing the description

- Fill in the repo's `.github/PULL_REQUEST_TEMPLATE.md` if present; leave irrelevant sections out rather than writing "N/A" walls.
- **What + why in 2–4 sentences.** Bullets only if there are several distinct changes.
- Add short notes only for things a reviewer or deployer must know (rollout order, follow-up PR, behaviour change on merge).
- **No checklist, no command list, no principle checkmarks.**
- Describe what the change IS. No rejected alternatives or session history.
- One line per paragraph; don't hard-wrap.

## Exception: a check could not be run or fails

Say so in one line (e.g. "Not tested end-to-end: Grafana rules only apply from prod."). Never imply something was verified when it wasn't.

## Diagrams: only for larger PRs

Add one small mermaid diagram when the PR is hard to grasp from text, e.g. it spans multiple components/services, introduces a new data flow or sequence, or is roughly 400+ changed lines of non-generated code. Small and single-component PRs get no diagram.

## Red flags

- Description longer than the interesting part of the diff → cut it.
- "Let me list the checks I ran" → no; CI shows that.
- "Reviewers should know I considered X" → no; state what the code does.
- "Tests probably pass" → run them before opening the PR.
