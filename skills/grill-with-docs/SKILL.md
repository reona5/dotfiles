---
name: grill-with-docs
description: A relentless interview to sharpen a plan or design, capturing the resulting 設計資料 (design decisions) as a comment on the branch's linked GitHub issue.
disable-model-invocation: true
---

Run a `/grilling` session that also produces 設計資料 — the design decisions that
crystallise as we talk. The one difference from the upstream skill: instead of
writing docs to files in the repo, post them as a **comment on the branch's linked
GitHub issue**.

## 1. Pull in the linked issue

Branches here often encode a GitHub issue number (e.g. `feat/2105-insight-index`).
Before grilling, run this and read its output:

```sh
~/.claude/skills/grill-with-docs/resolve-issue.sh
```

- If it prints an issue, treat that issue's title / body / 完成の定義 (acceptance
  criteria) / タスク / comments as the source of truth for what the work must
  accomplish. Grill the plan **against the issue** — surface gaps between the plan
  and what the issue asks for, unmet acceptance criteria, and unstated assumptions.
  This issue is also where the 設計資料 will be posted at the end.
- If it prints nothing (no issue number in the branch, or the fetch failed), grill
  the plan as-is. There is no issue to post to — at the end, fall back to showing
  the 設計資料 in the conversation (see step 4).

## 2. Grill relentlessly

Interview me relentlessly about every aspect of this until we reach a shared
understanding. Walk down each branch of the decision tree, resolving dependencies
between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before
continuing. Asking multiple questions at once is bewildering.

If a *fact* can be found by exploring the environment (filesystem, tools, etc.),
look it up rather than asking me. The *decisions*, though, are mine — put each one
to me and wait for my answer. When I use a fuzzy or overloaded term, sharpen it on
the spot so we're precise — but this is just to keep the grilling clear, not a
separate deliverable.

Do not act on it until I confirm we have reached a shared understanding.

## 3. Build the 設計資料 as you go

While grilling, accumulate the design decisions we reach into a working draft (keep
it in your working notes / a scratch file — do **not** write files into the repo;
the issue comment is their home).

Record a decision only when it's worth remembering: hard to reverse, surprising
without context, or the result of a real trade-off. If it's an obvious,
easily-reversed choice, skip it — keep the 設計資料 tight. Capture the decision the
moment it's made, don't batch it. Use the format in [DESIGN-FORMAT.md](./DESIGN-FORMAT.md).

## 4. Post the 設計資料 to the issue

When we reach shared understanding:

1. Assemble the accumulated decisions into a single markdown comment body. Docs get
   long and would make the issue noisy, so keep the **first view simple**: a short
   visible header line, then the actual 設計資料 collapsed inside one `<details>`
   block with a plain summary. No item counts, no English labels, no decoration —
   just `設計資料`:

   ```md
   `/grill-with-docs` session

   <details>
   <summary>設計資料</summary>

   ...design decisions in DESIGN-FORMAT.md format...

   </details>
   ```

   GitHub only renders the markdown inside `<details>` if there is a **blank line
   after `<summary>...</summary>`** and before `</details>` — keep those blank lines.
2. Show me the assembled body in the conversation.
3. Ask a yes/no confirmation before posting, with **Yes as the recommended default**
   — use AskUserQuestion and list the "Yes, post to issue #N" option first, marked
   `(推奨)`. Question: "Post the 設計資料 as a comment on issue #N?"
4. On **Yes**: write the body to a temp file and post it:

   ```sh
   ~/.claude/skills/grill-with-docs/post-doc.sh <body-file>
   ```

   Report the comment URL it prints.

   On **No**: leave the 設計資料 in the conversation and offer to revise it. Do not post.

If step 1 found no linked issue, skip the prompt and just present the 設計資料 in the
conversation; offer to save it to a file if I want one.
