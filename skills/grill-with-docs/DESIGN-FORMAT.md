# 設計資料 Format

設計資料 records *that* a decision was made and *why* — not much more.

## Template

Each decision is a short entry:

```md
## {決定の短いタイトル}

{1〜3文: どういう文脈で、何を決めたか、なぜそうしたか。}
```

That's it. One entry can be a single paragraph. The value is in recording *that* a
decision was made and *why* — not in filling out sections. List multiple decisions
as consecutive `##` entries.

## Optional additions

Only include these when they add genuine value. Most entries won't need them.

- **却下した選択肢** — only when the rejected alternatives are worth remembering
- **影響 / トレードオフ** — only when non-obvious downstream effects need calling out

## When a decision is worth recording

Record it when at least one of these holds:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will look at the code and wonder "why on earth did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If a decision is easy to reverse, skip it — you'll just reverse it. If it's not
surprising, nobody will wonder why. If there was no real alternative, there's
nothing to record beyond "we did the obvious thing." Keep the 設計資料 tight.

### What qualifies

- **Architectural shape.** "We're using a monorepo." "The write model is event-sourced, the read model is projected into Postgres."
- **Integration patterns between contexts.** "Ordering and Billing communicate via domain events, not synchronous HTTP."
- **Technology choices that carry lock-in.** Database, message bus, auth provider, deployment target. Not every library — just the ones that would take a quarter to swap out.
- **Boundary and scope decisions.** "Customer data is owned by the Customer context; other contexts reference it by ID only." The explicit no-s are as valuable as the yes-s.
- **Deliberate deviations from the obvious path.** "We're using manual SQL instead of an ORM because X." Anything where a reasonable reader would assume the opposite.
- **Constraints not visible in the code.** "We can't use AWS because of compliance requirements." "Response times must be under 200ms because of the partner API contract."
- **Rejected alternatives when the rejection is non-obvious.** If you considered GraphQL and picked REST for subtle reasons, record it — otherwise someone will suggest GraphQL again in six months.
