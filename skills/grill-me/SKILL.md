---
name: grill-me
description: A relentless interview to sharpen a plan or design.
disable-model-invocation: true
---

Run a `/grilling` session: a relentless interview to sharpen the plan or design at hand.

## First, pull in the linked issue (if the branch has one)

Branches here often encode a GitHub issue number (e.g. `feat/2105-insight-index`).
Before grilling, run this and read its output:

```sh
~/.claude/skills/grill-me/resolve-issue.sh
```

- If it prints an issue, treat that issue's title / body / 完成の定義 (acceptance
  criteria) / タスク / comments as the source of truth for what the work must
  accomplish. Grill the plan **against the issue**: surface gaps between the plan
  and what the issue actually asks for, unmet acceptance criteria, and unstated
  assumptions.
- If it prints nothing (no issue number in the branch, or the fetch failed),
  just grill the plan as-is.

Then conduct the grilling.
