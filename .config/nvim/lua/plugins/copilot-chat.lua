local status, chat = pcall(require, "CopilotChat")
if (not status) then return end

chat.setup({
  window = {
    layout = 'float',
    relative = 'cursor',
    width = 0.8,
    height = 0.8,
    row = 1
  },
  prompts = {
    Explain = {
      prompt = "/COPILOT_EXPLAIN 上記のコードを日本語で説明してください",
      mapping = ',ce',
      description = "コードの説明をお願いする",
    },
    Review = {
      prompt = '/COPILOT_REVIEW 選択したコードをレビューしてください。レビューコメントは日本語でお願いします。',
      mapping = ',cr',
      description = "コードのレビューをお願いする",
    },
    Fix = {
      prompt = "/COPILOT_FIX このコードには問題があります。バグを修正したコードを表示してください。説明は日本語でお願いします。",
      mapping = ',cf',
      description = "コードの修正をお願いする",
    },
    Optimize = {
      prompt = "/COPILOT_REFACTOR 選択したコードを最適化し、パフォーマンスと可読性を向上させてください。説明は日本語でお願いします。",
      mapping = ',co',
      description = "コードの最適化をお願いする",
    },
    Docs = {
      prompt = "/COPILOT_GENERATE 選択したコードに関するドキュメントコメントを日本語で生成してください。",
      mapping = ',cd',
      description = "コードのドキュメント作りをお願いする",
    },
    Tests = {
      prompt = "/COPILOT_TESTS 選択したコードの詳細なユニットテストを書いてください。説明は日本語でお願いします。",
      mapping = ',ct',
      description = "コードのテストコード作成をお願いする",
    },
    FixDiagnostic = {
      prompt = 'コードの診断結果に従って問題を修正してください。修正内容の説明は日本語でお願いします。',
      mapping = ',cd',
      description = "コードの静的解析結果に基づいた修正をお願いする",
      selection = require('CopilotChat.select').diagnostics,
    },
    Commit = {
      prompt =
      'commitize の規則に従って、変更に対するコミットメッセージを記述してください。 タイトルは最大50文字で、メッセージは72文字で折り返されるようにしてください。 メッセージ全体を gitcommit 言語のコードブロックでラップしてください。メッセージは日本語でお願いします。',
      mapping = ',cc',
      description = "コミットメッセージの作成をお願いする",
      selection = require('CopilotChat.select').gitdiff,
    },
    CommitStaged = {
      prompt =
      'commitize の規則に従って、ステージ済みの変更に対するコミットメッセージを記述してください。 タイトルは最大50文字で、メッセージは72文字で折り返されるようにしてください。 メッセージ全体を gitcommit 言語のコードブロックでラップしてください。メッセージは日本語でお願いします。',
      mapping = ',cs',
      description = "ステージ済みのコミットメッセージの作成をお願いする",
      selection = function(source)
        return require('CopilotChat.select').gitdiff(source, true)
      end,
    },
  },
})
