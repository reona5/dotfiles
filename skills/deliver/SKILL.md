---
name: deliver
description: The full delivery flow for the branch's linked issue — grill the plan, distill a spec, post it to the issue, implement, open a PR (assignee me, Copilot review), run a parallel multi-agent code review, then offer a retro.
disable-model-invocation: true
---

Run the full delivery flow for the branch's linked GitHub issue:

**grilling → spec → issue comment → 実装 → PR → parallel code review → 指摘対応 → retro**

Each phase feeds the next. Steps marked ✋ require my explicit confirmation
before you act — everything else you drive yourself.

## 1. Pull in the linked issue

Branches here often encode a GitHub issue number (e.g. `feat/2105-insight-index`).
Run this and read its output:

```sh
~/.claude/skills/deliver/resolve-issue.sh
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

Call the Skill tool with "grilling" and run that session. Grill the plan **against
the issue**: surface gaps between the plan and what the issue asks for, unmet
acceptance criteria, and unstated assumptions.

Ask the questions one at a time, waiting for feedback on each question before
continuing — this replaces grilling's rounds. Asking multiple questions at once is
bewildering. Still work the design tree: the next question comes from the frontier.

Put each question through the selection dialog the harness provides — `AskUserQuestion`
in Claude Code, the `questionnaire` tool in pi — with 2-4 concrete options and your
recommendation first. A decision I can settle with one keystroke beats a paragraph of
prose I have to reply to. Fall back to plain text only when no such tool exists.

Before asking, classify the question. If the answer is a fact you can observe —
current behavior, output, existing callers, whether an approach compiles or passes
a test — go observe it (read the code, run it, sketch a throwaway probe) and bring
me the result instead of the question. Spend my questions on product and preference
calls no experiment can settle.

When the change crosses a function or module boundary, sketch **two structurally
different designs** before settling it — types, signatures, and module boundaries
only, no implementation — and put the choice to me as a question with each sketch
in the option's `preview`.

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
a short visible header line, then the spec collapsed inside one `<details>` block.
The header line names the **activity**, not the skill — write `` `/grilling` セッション ``
and never the custom skill name: `/deliver` means nothing to the rest of the team,
while a grilling session is something they can read.

```md
`/grilling` セッション

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

Capture **before/after evidence** as you go — the PR body's Evidence section (step 6)
needs it. Before changing behavior, record the "before": a test that fails on the
current code, or the current output / screenshot. Run that test and watch it go
**red** on the unchanged code — a test that already passes proves nothing about the
change. After the change, record the same thing passing / changed. Grabbing the
"before" up front is the point; it can't be reconstructed once the code has moved on.

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

Call the Skill tool with `pr` for the body's shape — Summary (the smallest visual
that makes the change clear), Evidence (the before/after from step 5), Merge Danger
(one-way or two-way door, plus blast radius). Draft the PR and show me:

- **Title** — imperative, scoped to what the PR does
- **Body** — the `pr` skill's sections, plus the 主要な設計判断 a reviewer needs (one
  line each) and a reference to the issue (`Closes #N` only if this PR alone
  completes the issue's 完成の定義; otherwise a plain `#N` reference) — laid out in
  the template's structure when one exists, or in the `pr` skill's structure when not

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
review runs in **GPT via `codex exec`** (a different model, fresh context, no access
to this conversation) plus Copilot, and you neither review nor filter the findings
yourself. Your job here is orchestration only.

Write **four review prompts**, one per axis below, to `<dir>/<axis>.prompt.md` in a
fresh temp directory. Each gets a distinct axis and only the material its axis
needs, pasted into the prompt — never include your implementation narrative, your
rationale, or any "this should be correct" framing in a reviewer prompt:

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
4. **Standards** — does the code follow this repo's documented coding standards
   (`CODING_STANDARDS.md`, `CONTRIBUTING.md`, lint configs' intent, …), plus the
   code smells in [SMELL-BASELINE.md](SMELL-BASELINE.md)? Cite the rule for each
   documented-standard breach; label each smell as a judgement call.
   Material: diff + the standards files you found + SMELL-BASELINE.md pasted in full.

Tell each reviewer that findings must be anchored as `file:line`, and to report every
issue it finds — tagged with severity and confidence — rather than filtering its own
list; the adjudicator does the filtering. "No findings" is still an acceptable answer
when there genuinely are none, but never invent findings to fill the list. It may
read the repo to check context, but must not modify anything.

The Correctness axis also runs on Claude: in the same message as the command below,
spawn a subagent with the identical `correctness.prompt.md` content, so the same
question reaches two model families. A bug both raise independently is the
strongest signal this step produces.

Then run all four codex reviews concurrently in one command, read-only and without
persisting sessions:

```sh
root="$(git rev-parse --show-toplevel)"
for axis in correctness spec-fit tests standards; do
  profile=()
  [ "$axis" = correctness ] && profile=(-p review-correctness)
  codex exec "${profile[@]}" -s read-only --ephemeral -C "$root" \
    -o "<dir>/$axis.md" - < "<dir>/$axis.prompt.md" > "<dir>/$axis.log" 2>&1 &
done
wait
```

Correctness runs on the stronger model set in `~/.codex/review-correctness.config.toml`;
the other axes use the default `model` in `~/.codex/config.toml`. Model choice lives
in those files, not in this command.

Each `<dir>/<axis>.md` holds that reviewer's final message. If a run fails (empty
output — check its `.log`; `codex` needs network access, so it may have to run
outside the Bash sandbox), report it and continue with the reviews that did come
back; don't substitute your own review for the missing axis.

While codex runs, Copilot is reviewing too. Once all five reviews return,
fetch its comments and merge them into the same pool:

```sh
gh api "repos/{owner}/{repo}/pulls/$(gh pr view --json number -q .number)/comments" \
  --jq '.[] | select(.user.login | startswith("copilot")) | "\(.path):\(.line // .original_line) — \(.body)"'
```

Copilot usually takes a few minutes; if nothing has arrived yet, say so and move
on — offer to re-run this fetch after the fixes rather than blocking.

Then spawn a **Claude subagent — the adjudicator** — with the raw findings from all
sources (the four GPT reviews, the Claude Correctness review, Copilot), the diff,
the spec, and the issue. It verifies each finding against the actual code, dedupes
across sources while recording which sources raised each one (a finding raised
independently by GPT and Claude ranks above a single-source one), and sorts every
finding into one bucket with a one-line rationale:

- **Act on** — confirmed; would block a real PR (correctness, security, spec gap)
- **Consider** — legitimate, but the cost of fixing now is debatable; or plausible
  yet unverified
- **Noted** — valid but not actionable now (cosmetic, premature, low impact)
- **Dismissed** — wrong against the actual code, or missing context; with the reason

Standards findings (documented-standard breaches and smells) are judgement calls,
never placed above a confirmed bug. Relay its result as-is — do **not** re-filter
or veto findings yourself; an author dismissing critiques of their own code is
exactly the bias this setup exists to remove. If you disagree with a finding, say
so in your presentation, but the finding still goes to step 8.

## 8. Ask about each finding ✋

Put **every Act on and Consider finding to me individually with AskUserQuestion** —
one question per finding, batching up to 4 findings per call (the tool's limit)
until all have been asked. Each question carries:

- `question`: the finding's one-line claim and its failure scenario
- `header`: `file:line` (truncated to fit)
- options: **「修正する (推奨)」 first** for Act on findings; 「スキップ」 first for
  Consider findings. Give each option a description saying what the fix would
  touch / what skipping risks. If you (the author) disagree with an Act on finding,
  note that in the option description — the recommendation stays with the
  adjudicator's verdict.

List the Noted and Dismissed findings to me in one block, each with the
adjudicator's rationale; I'll name any I want promoted to a question.

Apply the chosen fixes, run the repo's tests again, then commit and push to the
same PR branch. Skipped, Noted, and Dismissed findings go into your final report so
nothing is silently dropped. If a fix changed the spec (a 主要な設計判断, the scope, or the agreed
behavior), don't post a new comment: edit the step-4 `/grilling` comment and append
a `## 変更点` section at the end of the spec, just before `</details>`. Write only
what changed and why — no backstory like 「レビューを受けて」, which means nothing to
a reader of the spec. Edit it with
`gh api --method PATCH repos/{owner}/{repo}/issues/comments/<comment-id> -F body=@<file>`,
after fetching the current body so the existing spec is kept intact.

## 9. Offer a retro

Once the fixes are pushed, ask me whether to run `/retro` on this session (it's
user-invoked, so suggest it — don't try to call it). Mention what would feed it:
findings from step 8 that a deterministic check (linter rule, pre-commit hook, CI
job) could have caught, and anything the Standards reviewer flagged that ought to be
written down as a repo standard. Skipping is fine; the flow is done either way.
