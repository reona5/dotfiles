# 仕様 Format

The spec is the bridge from grilling to implementation: tight enough to read in
one screen of an issue comment, complete enough that the implementation phase
never has to guess.

## Template

```md
## 背景

{1〜2文: なぜ今この作業をするか。issue 本文の繰り返しはしない — issue への補足だけ。}

## スコープ

### やること
- {…}

### やらないこと
- {…（明示的な「やらない」は「やる」と同じくらい価値がある）}

## 主要な設計判断

{grilling で固まった決定を DESIGN-FORMAT 形式で。記録する価値の基準も同じ:
不可逆 / 文脈なしでは不可解 / 実際のトレードオフの結果 — のどれかを満たすものだけ。
詳細は grill-with-docs/DESIGN-FORMAT.md を参照。}

### {決定の短いタイトル}

{1〜3文: どういう文脈で、何を決めたか、なぜそうしたか。}

## タスク

- [ ] {実装順。1 タスク = レビュー可能な 1 単位の変更}
- [ ] {…}

## 完成の定義との対応

{issue の完成の定義の各項目に対し、どのタスクで満たすかを対応付ける。
この PR で満たさない項目があれば、スコープ外の理由とともに明記する。}
```

## Notes

- 埋められないセクションがあるのは grilling が足りていないサイン。飾りで埋めず、
  step 2 に戻る。
- 「主要な設計判断」が空になるのは問題ない — 自明な作業に無理に決定をでっち上げない。
