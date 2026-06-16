---
name: llm-mutest-go
description:
  Given a bug report and a Go source file, writes a mutation-tested regression proof on a bugfix branch using gremlins.
  Invoke when asked to mutation-test a bug, validate a bugfix, or prove a regression test is meaningful.
license: MIT
metadata:
  language: go
  workflow: bug-validation
---

## Prerequisites — check all before starting

| What          | Check                        | If missing                                                                       |
| ------------- | ---------------------------- | -------------------------------------------------------------------------------- |
| Bug report    | Attached or pasted by user   | Ask for it. Do not proceed.                                                      |
| Source file   | Named in the bug report      | Ask for the path. Do not proceed.                                                |
| Gremlins      | `gremlins unleash --version` | Ask to install: `go install github.com/go-gremlins/gremlins/cmd/gremlins@latest` |
| Bugfix branch | `git branch --show-current`  | If on `main`/`master`, ask to create or switch.                                  |

---

## Steps

**1. Parse the bug report** Extract: affected function, root cause, expected vs actual behaviour. Summarise in one
sentence. Ask if ambiguous.

**2. Read the source file** Find the buggy function. Note its signature, package name, and any same-package helpers it
uses.

**3. Write the regression test → `<file>_bugfix_test.go`**

- One `func TestBugfix_<Fn>_<Description>(t *testing.T)`
- Table-driven, rows named after the bug (`"bug: off-by-one on last element"`)
- `package <pkg>_test` unless internal access is needed
- stdlib only — no third-party helpers
- Must be **red on buggy code**: `go test ./... -run TestBugfix_...` → FAIL. Revise if it passes.

**4. Apply the fix** _(skip if user already has one)_ Propose a minimal diff. Ask for confirmation. Apply only the
targeted change.

**5. Verify green** `go test ./... -run TestBugfix_...` → must PASS. Do not continue until it does.

**6. Run gremlins** _(scoped to the affected file — never run unscoped on large modules)_

```
gremlins unleash --tags <file>.go --coverpkg ./...
```

**7. Kill surviving mutants** For each `LIVED`/`NOT COVERED` mutant in the affected function:

- Describe what changed and why the test missed it.
- Add a table row or new test to kill it.
- Re-run gremlins. Repeat up to 3 rounds. After 3, mark remaining as equivalent mutants and stop.

**8. Report**

```
Bug:      <one-liner>
File:     <path>   Function: <name>   Branch: <branch>
Test:     <file>_bugfix_test.go — red before fix ✓  green after ✓
Gremlins: X/X killed in affected function
Survivors: none ✓  (or list with explanation)
```

---

## Rules

- Never touch `main`/`master` directly.
- `NOT COVERED` for all mutants = test isn't hitting the right code path — check package and run filter.
- Equivalent mutants are acceptable survivors — document them.
