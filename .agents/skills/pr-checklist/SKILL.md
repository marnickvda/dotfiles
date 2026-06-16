---
name: pr-checklist
description:
  Use when creating or updating a pull request description — adds a "Checklist" section with checkmarks proving tests
  pass and the change was reviewed against DRY, KISS, YAGNI, SOLID, and scope discipline.
---

# PR Checklist

## Overview

PR descriptions should prove the work was actually done, not just claim it was. A short checklist with the exact
commands run and honest review notes makes the diff trustworthy for reviewers.

## When to Use

- Creating a new PR with `gh pr create`
- Updating an existing PR description (`gh pr edit`)
- Any time the PR body is being (re)written

## Placement

```markdown
<!-- rest of repo PR template -->

## Checklist

- [x] All tests pass — `<exact command run>`
- [x] Lint/format/typecheck clean — `<exact command run>`
- [x] Reviewed comments — stripped noise, kept only non-obvious "why"
- [x] DRY — no duplicated logic introduced
- [x] KISS — code is simple to read and maintain (low complexity), not just quick to write
- [x] YAGNI — no speculative code or unused abstractions
- [x] SOLID — responsibilities are clear and isolated
- [x] Change scope verified — added/removed code directly serves the stated problem; no drive-by edits
```

## Rules

- **Only check a box if you actually did it.** No performative checkmarks.
- **Show the real command** from this repo (e.g. `pnpm test`, `pnpm lint`, `cargo test`), never a generic placeholder.
- **If something fails or doesn't apply, leave it unchecked** and add a one-line note why (e.g.
  `- [ ] Lint — not configured in this package`).
- **Never invent results.** If you didn't run tests, the box stays empty.
- **Describe what the change IS, not what it isn't.** Do not narrate rejected alternatives, abandoned approaches, or
  decisions made during the session ("no in-memory dedupe", "did not add retries", "considered X but chose Y"). The
  reviewer opens the PR cold and has no context for these. They confuse more than they reassure. If a non-obvious
  trade-off truly matters, state it as a positive property of the current code (e.g. "Relies on UDD's `DISTINCT ON`
  contract") — not as a list of things you didn't do.

## Definitions (so you check honestly)

| Principle | What it means here                                                                                                               |
| --------- | -------------------------------------------------------------------------------------------------------------------------------- |
| DRY       | No duplicated logic introduced by this change. Repeating literals or shape is fine if abstracting would couple unrelated things. |
| KISS      | Simple to **read and maintain** (opposite of complex). Not "quick to write" or "clever one-liner".                               |
| YAGNI     | No code added for hypothetical future needs. Every new abstraction has a current caller.                                         |
| SOLID     | Each new/changed unit has one clear responsibility; dependencies point inward; no leaky abstractions.                            |
| Scope     | Every added/removed line traces back to the problem stated in the PR title/summary. No unrelated refactors.                      |

## Red Flags — Do Not Check the Box

- "Tests probably pass, I didn't change much" → run them.
- "It's simple enough, KISS is fine" → re-read the diff as a stranger first.
- "I'll tidy that unrelated thing while I'm here" → that's a scope violation; either revert or split the PR.
- "The abstraction will be useful later" → YAGNI violation; remove it.
- "Let me explain why I didn't do X" → cut it. Reviewers don't share your session context. State what the code does, not
  what it doesn't.

## Quick Reference

1. Run tests and lint/typecheck. Capture the exact commands.
2. Re-read the diff with the table above in mind.
3. Fill in the checklist honestly — unchecked boxes are fine and informative.
4. Insert into the PR body, then continue with the repo's standard template.
