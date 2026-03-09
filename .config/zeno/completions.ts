import { defineConfig } from "jsr:@yuki-yano/zeno";
import { join } from "jsr:@std/path@^1.0.0/join";

export default defineConfig(({ projectRoot, currentDirectory }) => ({
  completions: [
    {
      name: "kill signal",
      patterns: ["^kill -s $"],
      sourceCommand: "kill -l | tr ' ' '\\n'",
      options: { "--prompt": "'Kill Signal> '" },
    },
    {
      name: "kill pid",
      patterns: ["^kill( .*)? $"],
      excludePatterns: [" -[lns] $"],
      sourceCommand: "LANG=C ps -ef | sed 1d",
      options: { "--multi": true, "--prompt": "'Kill Process> '" },
      callback: "awk '{print $2}'",
    },
    {
      name: "chdir",
      patterns: ["^cd $"],
      sourceCommand:
        "find . -path '*/.git' -prune -o -maxdepth 5 -type d -print0",
      options: {
        "--read0": true,
        "--prompt": "'Chdir> '",
        "--preview": "cd {} && ls -a | sed '/^[.]*$/d'",
      },
      callback: "cut -z -c 3-",
      callbackZero: true,
    },
    {
      name: "npm scripts",
      patterns: ["^npm run $"],
      sourceFunction: async ({ projectRoot }) => {
        try {
          const pkgPath = join(projectRoot, "package.json");
          const pkg = JSON.parse(
            await Deno.readTextFile(pkgPath),
          ) as { scripts?: Record<string, unknown> };
          return Object.keys(pkg.scripts ?? {});
        } catch {
          return [];
        }
      },
      options: { "--prompt": "'npm scripts> '" },
      callbackFunction: ({ selected, expectKey }) => {
        if (expectKey === "alt-enter") {
          return selected.map((script) => `${script} -- --watch`);
        }
        return selected;
      },
      previewFunction: async ({ item, context }) => {
        try {
          const pkgPath = join(context.projectRoot, "package.json");
          const pkg = JSON.parse(
            await Deno.readTextFile(pkgPath),
          ) as { scripts?: Record<string, string> };
          const script = pkg.scripts?.[item];
          return script ? `${item}\n${script}` : item;
        } catch {
          return item;
        }
      },
    },
  ],
}));
