---
name: to-ticket
description: Post a document from the conversation (仕様, 設計資料, notes) as a collapsed comment on the branch's linked GitHub issue.
disable-model-invocation: true
---

Post a document that crystallised in this conversation — a 仕様 from `/to-spec`,
設計資料, or similar — as a **comment on the branch's linked GitHub issue**.

## 1. Determine what to post

The document is usually the most recent deliverable in the conversation. If it's
ambiguous which one I mean, ask.

## 2. Format the comment body

Docs get long and would make the issue noisy, so keep the **first view simple**: a
short visible header line saying what this is (and which skill session produced it,
e.g. `` `/to-spec` session ``), then the document collapsed inside one `<details>`
block with a plain summary naming the document type — `仕様`, `設計資料`, etc. No
item counts, no English labels, no decoration:

```md
`/to-spec` session

<details>
<summary>仕様</summary>

...document body...

</details>
```

GitHub only renders the markdown inside `<details>` if there is a **blank line
after `<summary>...</summary>`** and before `</details>` — keep those blank lines.

## 3. Confirm and post ✋

Show me the assembled body, then ask a yes/no confirmation before posting, with
**Yes as the recommended default** — use AskUserQuestion and list the "Yes, post to
issue #N" option first, marked `(推奨)`. On **Yes**, write the body to a temp file
and post it:

```sh
~/.claude/skills/to-ticket/post-comment.sh <body-file>
```

Report the comment URL it prints. On **No**, leave the document in the
conversation and offer to revise it. Do not post.

If the branch has no resolvable issue number, the script fails with a message —
in that case ask me for the issue number and post with
`gh issue comment <num> --body-file <file>` instead, after the same confirmation.
