---
name: grill-to-pr
description: The full delivery flow for the branch's linked issue — grill the plan, distill a spec, post it to the issue, implement, open a PR (assignee me, Copilot review), then run a parallel multi-agent code review.
disable-model-invocation: true
---

Run the full delivery flow for the branch's linked GitHub issue:

**grilling → spec → issue comment → 実装 → PR → parallel code review → 指摘対応**

Each phase feeds the next. Steps marked ✋ require my explicit confirmation
before you act — everything else you drive yourself.

## 1. Pull in the linked issue

Branches here often encode a GitHub issue number (e.g. `feat/2105-insight-index`).
Run this and read its output:

```sh
~/.claude/skills/grill-to-pr/resolve-issue.sh
```

- If it prints an issue, treat its title / body / 完成の定義 (acceptance criteria) /
  タスク / comments as the source of truth for what the work must accomplish. This
  issue is also where the spec will be posted (step 4).
- If it prints nothing (on the default branch, no number in the branch name, or the
  fetch failed): ask me for the issue number, fetch it with `gh issue view`, and —
  if we're not on a work branch yet — create one named `<type>/<number>-<short-slug>`
  so the rest of the flow (and its scripts) can resolve the issue from the branch.
  If there is genuinely no issue, say so and offer to run the flow anyway with the
  spec staying in the conversation (step 4 is skipped).

## 2. Grill relentlessly

Interview me relentlessly about every aspect of this until we reach a shared
understanding. Grill the plan **against the issue**: surface gaps between the plan
and what the issue asks for, unmet acceptance criteria, and unstated assumptions.
Walk down each branch of the decision tree, resolving dependencies between
decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before
continuing. Asking multiple questions at once is bewildering.

If a *fact* can be found by exploring the environment (filesystem, tools, etc.),
look it up rather than asking me. The *decisions*, though, are mine — put each one
to me and wait for my answer.

As we talk, accumulate three things in your working notes (not in repo files):

- **主要な設計判断** — decisions worth remembering, per the criteria in
  [grill-with-docs/DESIGN-FORMAT.md](../grill-with-docs/DESIGN-FORMAT.md)
- **スコープ** — what's in, and explicitly what's out
- **タスク分解の材料** — the natural units of work that emerge

Do not move to step 3 until I confirm we have reached a shared understanding.

## 3. to-spec: distill the spec

Assemble the accumulated material into a spec using the format in
[to-spec/SPEC-FORMAT.md](../to-spec/SPEC-FORMAT.md) — this step is the standalone
`/to-spec` skill, run inline. Show the spec to me in the conversation.

## 4. to-ticket: post the spec to the issue ✋

Specs get long and would make the issue noisy, so keep the **first view simple**:
a short visible header line, then the spec collapsed inside one `<details>` block:

```md
`/grill-to-pr` session

<details>
<summary>仕様</summary>

...spec in SPEC-FORMAT.md format...

</details>
```

GitHub only renders the markdown inside `<details>` if there is a **blank line
after `<summary>...</summary>`** and before `</details>` — keep those blank lines.

Ask a yes/no confirmation before posting, with **Yes as the recommended default**
— use AskUserQuestion and list the "Yes, post to issue #N" option first, marked
`(推奨)`. On **Yes**, write the body to a temp file and post it:

```sh
~/.claude/skills/to-ticket/post-comment.sh <body-file>
```

Report the comment URL it prints. On **No**, revise the spec with me and re-ask.

## 5. Implement

Work through the spec's タスク in order, tracking them with the task tools so I can
follow progress. Match the surrounding code's style and idioms. Run whatever tests
and linters the repo already has — don't invent new infrastructure.

If implementation reveals the spec was wrong somewhere, stop and tell me: we adjust
the spec first (and note the deviation for the PR body), then continue. Silent
drift between spec and code defeats the whole flow.

Do not commit or push during this step — that happens at the step 6 checkpoint.

## 6. Open the PR ✋

First check whether the repo has a PR template:

```sh
ls .github/PULL_REQUEST_TEMPLATE.md .github/pull_request_template.md \
   PULL_REQUEST_TEMPLATE.md docs/PULL_REQUEST_TEMPLATE.md \
   .github/PULL_REQUEST_TEMPLATE/ 2>/dev/null
```

If a template exists, **the body must follow it**: keep its structure — headings,
checklists, HTML comments' instructions — and fill each section; write `N/A`
rather than deleting a section that doesn't apply. If `.github/PULL_REQUEST_TEMPLATE/`
holds multiple templates, ask me which one to use. Fold the content described
below into the template's corresponding sections instead of adding your own.

Draft the PR and show me:

- **Title** — imperative, scoped to what the PR does
- **Body** — a short summary, the 主要な設計判断 that a reviewer needs (one line
  each), a reference to the issue (`Closes #N` only if this PR alone completes the
  issue's 完成の定義; otherwise a plain `#N` reference), and what was tested —
  laid out in the template's structure when one exists, or as-is when not

This single confirmation covers commit, push, and PR creation. Once I approve:

```sh
git push -u origin "$(git branch --show-current)"
gh pr create --assignee @me --title "<title>" --body-file <body-file>
gh api --method POST \
  "repos/{owner}/{repo}/pulls/$(gh pr view --json number -q .number)/requested_reviewers" \
  -f 'reviewers[]=copilot-pull-request-reviewer[bot]'
```

The `gh api` call is how you request a **Copilot review** — `--reviewer` on
`gh pr create` does not accept the bot. If the call fails (Copilot review not
enabled on the repo), report it and continue; don't block the flow on it.

## 7. Parallel code review

You wrote this code, so **you are the most biased reviewer available** — the
review runs in subagents (fresh context, no access to this conversation), and you
neither review nor filter the findings yourself. Your job here is orchestration
only.

Spawn **three review agents in a single message** so they run concurrently. Each
gets a distinct axis and only the material its axis needs — never include your
implementation narrative, your rationale, or any "this should be correct" framing
in a reviewer prompt:

1. **Correctness** — bugs, edge cases, race conditions; every finding needs a
   concrete failure scenario (inputs/state → wrong outcome).
   Material: the PR diff (`git diff <base>...HEAD`) and the issue only — no spec,
   so the author's design story can't anchor it.
2. **Spec fit** — spec のタスク・完成の定義との突き合わせ; anything the issue asks
   for that the diff doesn't deliver.
   Material: diff + spec + issue.
3. **Tests & regressions** — missing coverage for the new behavior, existing
   behavior the diff could break.
   Material: diff + spec (for what the intended behavior is).

Tell each agent that findings must be anchored as `file:line`, and that **"no
findings" is an acceptable answer** — padding with nitpicks is worse than silence.

While the agents run, Copilot is reviewing too. Once all three agents return,
fetch its comments and merge them into the same pool:

```sh
gh api "repos/{owner}/{repo}/pulls/$(gh pr view --json number -q .number)/comments" \
  --jq '.[] | select(.user.login | startswith("copilot")) | "\(.path):\(.line // .original_line) — \(.body)"'
```

Copilot usually takes a few minutes; if nothing has arrived yet, say so and move
on — offer to re-run this fetch after the fixes rather than blocking.

Then spawn a **fourth agent — the adjudicator** — with the raw findings from all
sources (the three agents + Copilot), the diff, the spec, and the issue. It
verifies each finding against the actual code, drops what it can't confirm (marking
borderline ones as unverified rather than deleting them), dedupes across sources,
and ranks the survivors by severity. Relay its result as-is — do **not** re-filter
or veto findings yourself; an author dismissing critiques of their own code is
exactly the bias this setup exists to remove. If you disagree with a finding, say
so in your presentation, but the finding still goes to step 8.

## 8. Ask about each finding ✋

Put **every surviving finding to me individually with AskUserQuestion** — one
question per finding, batching up to 4 findings per call (the tool's limit) until
all have been asked. Each question carries:

- `question`: the finding's one-line claim and its failure scenario
- `header`: `file:line` (truncated to fit)
- options: **「修正する (推奨)」 first** when the adjudicator confirmed the
  finding; put 「スキップ」 first instead for findings it marked unverified or
  cosmetic. Give each option a description saying what the fix would touch / what
  skipping risks. If you (the author) disagree with a confirmed finding, note that
  in the option description — the recommendation stays with the adjudicator's
  verdict.

Apply the chosen fixes, run the repo's tests again, then commit and push to the
same PR branch. Skipped findings go into your final report so nothing is silently
dropped. If a fix changed one of the spec's 主要な設計判断, post a short follow-up
comment to the issue saying what changed and why.
