---
name: to-spec
description: Distill the discussion at hand (a grilling session, a plan, a design conversation) into a 仕様 in SPEC-FORMAT.md format, shown in the conversation.
disable-model-invocation: true
---

Distill what we've discussed so far — a grilling session, a plan, or any design
conversation — into a 仕様 (spec).

## 1. Pull in the linked issue (if the branch has one)

Branches here often encode a GitHub issue number (e.g. `feat/2105-insight-index`).
Run this and read its output:

```sh
~/.claude/skills/to-spec/resolve-issue.sh
```

- If it prints an issue, use its 完成の定義 (acceptance criteria) for the spec's
  「完成の定義との対応」 section.
- If it prints nothing, write the spec without that mapping and note that no
  linked issue was found.

## 2. Assemble the spec

Use the format in [SPEC-FORMAT.md](./SPEC-FORMAT.md). The material is the
conversation so far — don't invent content that wasn't discussed.

If a section can't be filled because the discussion never covered it, don't pad it
with plausible filler: ask me the missing questions first, one at a time, with your
recommended answer for each. A spec with honest gaps surfaced beats a complete-looking
one built on guesses.

## 3. Show it

Present the spec in the conversation and ask for corrections. Do **not** write it
to repo files or post it anywhere — if I want it on the issue, I'll run
`/to-ticket` next (or you may suggest it).
