---
name: grill-me
description: A relentless interview to sharpen a plan or design.
disable-model-invocation: true
---

Call the Skill tool with "grilling", then run that session with the local additions below.

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

## Ask one question at a time, with options

Ask the questions one at a time, waiting for feedback on each question before
continuing — this replaces grilling's rounds. Asking multiple questions at once is
bewildering. Still work the design tree: the next question comes from the frontier.

Put each question through the selection dialog the harness provides — `AskUserQuestion`
in Claude Code, the `questionnaire` tool in pi — with 2-4 concrete options and your
recommendation first. A decision I can settle with one keystroke beats a paragraph of
prose I have to reply to. Fall back to plain text only when no such tool exists.
