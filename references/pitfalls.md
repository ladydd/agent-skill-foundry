# Known Pitfalls

Use this file when reviewing a new skill for problems we have already seen in real development.

## Input UX

Problem: Agent asks for keyword, market, category, or entity ID when the Excel/CSV already contains it.

Fix: Add `inspect-inputs` and tell the agent to ask only for the root folder or required source file.

## Wrong Continuation Directory

Problem: A second skill scans local folders and chooses the wrong latest run.

Fix: Require the first skill to print the project directory. Require the second skill to use only the path present in the current context; otherwise stop.

## Missing Run Directory Discipline

Problem: A skill writes outputs beside source Excel files or into a reused test folder, making later skills pick up stale JSON.

Fix: `run` must create a new empty run/project directory and write a manifest first. Only `attach-*` commands may intentionally update an existing run.

## HTML Detached from Trace Data

Problem: HTML looks right but the numbers cannot be traced to JSON or CSV basis files.

Fix: Render HTML from `report_data.json` or an equivalent typed view model, and keep raw, cleaned, analysis, and display data separate.

## Missing Runtime Source

Problem: A packaged skill contains a Python launcher but not the module it imports.

Fix: Use Go binaries for user-facing packages or include all runtime dependencies. Test from the installed skill path, not only the development path.

## Too Many Files in tools/bin

Problem: `tools/bin` contains wrappers, old binaries, source fragments, and debug files.

Fix: For Go skills, keep exactly four platform binaries.

## macOS Quarantine

Problem: macOS refuses to run downloaded binaries.

Fix: Put this in `INSTRUCTIONS.md`:

```bash
xattr -dr com.apple.quarantine ./tools/bin 2>/dev/null || true
chmod +x ./tools/bin/<cli-prefix>-darwin-amd64 ./tools/bin/<cli-prefix>-darwin-arm64 2>/dev/null || true
```

## Windows Encoding Damage

Problem: Chinese JSON written via PowerShell here-string becomes `????`.

Fix: Do not write Chinese JSON via shell stdin or default `Out-File`. Use UTF-8 file writing, editor/apply patch, or CLI-owned JSON generation. Always scan for `???`.

## Agent Does Too Much Calculation

Problem: Agent manually recalculates metrics, causing inconsistent results.

Fix: Put calculations in CLI and tell agent to quote CLI outputs only.

## Agent Does Too Little Judgment

Problem: CLI tries to infer semantic labels from weak text rules where agent judgment is more appropriate.

Fix: Let agent write structured JSON for semantic labeling. Then let CLI validate coverage, normalize labels, calculate, and render.

## Optional Research Overclaims

Problem: Public web snippets are written as due-diligence conclusions.

Fix: Separate `evidence_summary` from `action_summary`; mark confidence; keep optional research from overturning structured data.

## HTML Detail Overload

Problem: A long list in one table cell makes the whole row ugly.

Fix: Show count by default and fold details:

```text
展开 8 条站内动作
```

## Hidden Internal Terms

Problem: User-facing docs or HTML mention internal backend, token, vendor account, or project nicknames.

Fix: Use public terms like `自动补充数据` and scan docs/artifacts before release.

## Two-Layer Zip

Problem: User unzips a package and gets a nested duplicate folder.

Fix: Package the skill folder contents intentionally and verify the unzip shape.

## Stale HTML Template

Problem: Agent test shows old HTML layout because the binary was not rebuilt after template changes.

Fix: After any Go template or renderer change, run `go test ./...`, `./build.sh`, then regenerate a real HTML.
