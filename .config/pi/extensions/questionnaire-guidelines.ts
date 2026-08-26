import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// questionnaire ツール（himorishige/pi-coding-agent-extensions）は promptSnippet と
// promptGuidelines を持たないため、API のツールスキーマには載るが system prompt の
// Available tools / Guidelines には現れない。pi の既定 Guidelines は2行しかなく、
// 結果としてモデルは選択ダイアログをほぼ呼ばずに散文で選択肢を並べてしまう。
// パッケージ本体に書き足すと pi update で消えるので、system prompt 側から補う。

const MARKER = "questionnaire tool renders a selection dialog";

const GUIDELINES = `Asking the user:
- The ${MARKER} in the TUI. Use it whenever you are blocked on a decision that is
  genuinely the user's to make and cannot be resolved from the request, the code, or
  a sensible default.
- Give each question 2-4 concrete options, and put your recommended option first with
  "(推奨)" in its label. A decision the user settles with one keystroke beats a
  paragraph of prose they have to reply to.
- Ask one question per questionnaire call and wait for the answer before the next one,
  unless the questions are genuinely independent.
- Do not use questionnaire for facts you can verify yourself, for choices with a
  conventional default, or to ask whether to proceed — just proceed.`;

export default function (pi: ExtensionAPI) {
  pi.on("before_agent_start", (event) => {
    // questionnaire が無効なセッション（--tools 絞り込みなど）では何も足さない。
    if (!pi.getActiveTools().includes("questionnaire")) return;
    // 他の handler や再入で二重に足さない。
    if (event.systemPrompt.includes(MARKER)) return;

    return { systemPrompt: `${event.systemPrompt}\n\n${GUIDELINES}` };
  });
}
