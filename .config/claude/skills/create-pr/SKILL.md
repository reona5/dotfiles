---
name: create-pr
description: GitHub Project の PBI(issue)番号を渡して、現在のブランチから draft PR を作成する。ユーザーが「PR を作って」「PBI 2099 の PR」「create-pr」等と言ったときに使う。PBI 番号は引数で渡す（省略時はブランチ名から推測）。lt-silkhat/lmoni の PR テンプレート・Conventional Commits・draft 運用に準拠。
---

# create-pr — PBI から draft PR を作成する

GitHub Project の PBI（= GitHub issue）番号を引数で受け取り、現在のブランチの変更を
**draft PR** として作成する。PR タイトル・本文はリポジトリの規約とテンプレートに沿って生成する。

## PBI について

- PBI は GitHub Project **lt-silkhat/projects/11**（https://github.com/orgs/lt-silkhat/projects/11）
  の item であり、実体は `lt-silkhat/lmoni` の **GitHub issue**。よって PBI 番号 = issue 番号。
- Project 11 の `Status` フィールドの選択肢:
  `Todo` / `In Progress` / `In Review` / `In Testing` / `ready to merge` /
  `In Testing (Fixed)` / `Done` / `Done (Deployed)` / `Todo (Icebox)` /
  `Todo (Available)` / `Todo (Available) 2`。

## 引数

- `$ARGUMENTS` に PBI(issue) 番号を渡す（例: `/create-pr 2099`）。
- 番号が省略された場合:
  1. 現在のブランチ名から数字を抽出する（例 `feat/2099` → `2099`）。
  2. 抽出できなければ、ユーザーに PBI 番号を確認する（勝手に推測しない）。

## 前提の確認（PR 作成前に必ず実行）

1. リポジトリを確認: `gh repo view --json nameWithOwner -q .nameWithOwner`。
2. 現在のブランチが `main` でないこと: `git rev-parse --abbrev-ref HEAD`。
   `main` の場合は中止し、作業ブランチを切るよう促す。
3. 未コミットの変更がないこと: `git status --short`。あれば、コミットしてから来るよう促す
   （このスキルはコミットしない）。
4. `main` との差分コミットがあること: `git log --oneline origin/main..HEAD`。
   空なら「コミットが無い」旨を伝えて中止。

## 手順

### 1. PBI(issue) 情報を取得
```bash
gh issue view <PBI番号> --json number,title,body,url,labels
```
タイトル・本文（概要 / 完成の定義 / タスク）を読み、PR の内容生成に使う。
issue が見つからない場合はユーザーに番号を確認する。

### 2. ブランチを push
```bash
git push -u origin <現在のブランチ>
```
- pre-push フックは無いので、通常はそのまま通る。
- push が engine エラー等で失敗する場合は、このリポジトリのツールチェーン制約
  （node ^24 / pnpm ^10）が原因のことがある。その場合はユーザーのメモリ
  `toolchain-node24-pnpm10` の手順（`mise exec node@24 -- npx pnpm@10 ...` / pnpm シム）を参照する。

### 3. PR タイトルを決める
- **Conventional Commits** 形式（`type(scope): 説明`、日本語可）。
  例: `feat: エルナレ用ライン一覧ページを追加`、`chore(cdk): ...`。
- 基本は `main..HEAD` のコミット群と PBI タイトルから要約する。単一コミットなら
  そのコミットの subject を流用してよい。

### 4. PR 本文を生成
リポジトリの `.github/pull_request_template.md` を**必ず読み込み**、その構成を埋める。
現行テンプレートの各セクション:

- **チケットへのリンク**: `Issue URL:` に PBI issue の URL を貼る
  （PBI は複数 PR にまたがり得るので、原則 `Closes #<n>` は付けない。
  この PR で PBI が完了する場合のみ、ユーザー確認の上 `Closes` を付ける）。
- **このPull Requestの目的**: なぜやるか（PBI の「なぜやるのか」を要約）。
- **やったこと**: `main..HEAD` の変更内容を箇条書き。
- **やらないこと**: スコープ外。無ければ「なし」。
- **動作確認**: 実施した確認（type-check / build / 手動確認等）をチェックリストで。
- **コンテキスト更新**: 変更内容に応じて AGENTS.md / パッケージ CLAUDE.md / README の
  更新要否を確認し、該当なしならチェックを入れる。
- **その他**: レビュワー向けの注意点があれば。

本文は一時ファイルに書き、`--body-file` で渡す（改行・特殊文字の事故防止）。
scratchpad ディレクトリを使う。

### 5. draft PR を作成
```bash
gh pr create --draft --base main \
  --title "<Conventional Commits タイトル>" \
  --body-file <一時ファイル>
```
- **既定は draft**（`--draft`）。ユーザーが「レビュー依頼まで」等と明示した場合のみ
  `--draft` を外す。
- コミットメッセージにも PR 本文にも **Co-Authored-By や AI 生成フッターは付けない**
  （このリポジトリの規約）。

### 6. 結果を報告
作成された PR の URL を提示する。必要に応じて、GitHub Project 上のステータス更新
（例 Todo → In Review）を行うか確認する（自動では変更しない）。

## 注意

- このスキルは **コミットしない**。コミット済み・push 可能な状態を前提とする。
- `gh` は cwd のリポジトリを自動判定する。別リポジトリで使う場合もそのまま動く
  （テンプレートが無いリポジトリでは、簡潔な目的/やったこと/動作確認の本文を生成する）。
- 破壊的操作ではないが、PR 作成は外部公開なので、タイトル・本文をユーザーに提示してから
  作成する（レビューの一手間を挟む）。
