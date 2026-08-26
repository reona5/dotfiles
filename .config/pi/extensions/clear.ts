import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// `/clear` を `/new` のエイリアスにする。
// 組み込みの /new はセッションを新規作成するだけなので、
// ctx.newSession() で同等の振る舞いを再現する。
export default function (pi: ExtensionAPI) {
  pi.registerCommand("clear", {
    description: "Start a new session (alias for /new)",
    handler: async (_args, ctx) => {
      await ctx.newSession();
    },
  });
}
