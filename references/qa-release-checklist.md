# QA and Release Checklist

Use this checklist before saying a skill is ready for users.

## 1. Structure

Check:

```bash
find <skill_folder> -maxdepth 3 -type f | sort
```

Required:

- `SKILL.md`
- `INSTRUCTIONS.md`
- `references/`
- `tools/bin/` if the skill has a CLI

Recommended:

- `AGENTS.md`
- `agents/openai.yaml` if the distribution supports UI metadata

## 2. Skill Metadata

Run the official skill validator when the target runtime provides one. The command shape is usually:

```bash
<skill-validator> <skill_folder>
```

If no validator is available in the target runtime, do not claim validator success. Record it as not run and list the local structure/package checks used instead.

Check:

- frontmatter has only required public fields
- `description` contains trigger conditions
- continuation skills mention the required upstream `PROJECT_ROOT`
- no TODO placeholders remain

## 3. Go CLI

Run:

```bash
cd <skill_project>/go-cli
go test ./...
./build.sh
```

Then run the meta-skill package gate:

```bash
<meta-skill>/scripts/check_skill_package.sh <skill_folder> <cli-prefix>
```

Check:

```bash
find <skill_folder>/tools/bin -maxdepth 1 -type f -exec basename {} \; | sort
file <skill_folder>/tools/bin/*
```

Expected four binaries only:

- `*-linux-amd64`
- `*-darwin-amd64`
- `*-darwin-arm64`
- `*-windows-amd64.exe`

Linux/macOS binaries must be executable. macOS instructions must include:

```bash
xattr -dr com.apple.quarantine ./tools/bin 2>/dev/null || true
chmod +x ./tools/bin/<cli-prefix>-darwin-amd64 ./tools/bin/<cli-prefix>-darwin-arm64 2>/dev/null || true
```

## 4. CLI Smoke Test

Run on a local real fixture, redacted fixture, or synthetic fixture:

```bash
<cli> inspect-inputs <fixture_or_dir>
<cli> run <fixture_or_dir> --output <run_dir>
```

If optional append exists:

```bash
<cli> attach-... --output-dir <run_dir> --research-json <json>
```

Verify:

- run directory created
- run directory was fresh or explicitly reused only for `attach-*`
- manifest exists
- analysis JSON exists
- intermediate JSON trace exists
- `report_data.json` exists for HTML reports
- final HTML exists
- optional CSV/XLSX basis exists when expected
- final response prints the run path
- final response prints `PROJECT_ROOT=...` only for multi-skill handoff

## 5. Generated Artifact Check

Run:

```bash
<meta-skill>/scripts/check_run_artifact.sh <run_or_project_dir>
```

This should parse JSON, find HTML, scan for mojibake, and reject external runtime assets.

## 6. Real Agent Test

Do not rely only on direct CLI execution. Start a fresh agent context with the installed skill and a realistic user prompt.

Record evidence in a local release note or test log:

```text
Skill path:
Prompt:
Fixture path:
Selected binary:
Commands observed:
Output directory:
Final artifact:
Pass/fail:
Failures:
```

Watch for:

- asks for unnecessary input
- selects wrong project/run directory
- calls wrong platform binary
- leaks private config wording
- writes malformed JSON
- uses unsupported PowerShell encoding path
- fails to highlight output path
- claims optional work happened when it did not

Continuation skill negative tests:

1. Prompt contains `PROJECT_ROOT=<path>` and newer-looking runs exist nearby: agent must use `PROJECT_ROOT` only.
2. Prompt lacks `PROJECT_ROOT`: agent must stop, not ask for raw source files, not scan for latest.
3. `PROJECT_ROOT` exists but manifest is missing/invalid: agent must stop.

## 7. Public-Safety Scan

Run:

```bash
<meta-skill>/scripts/check_forbidden_terms.sh <skill_folder>
<meta-skill>/scripts/check_forbidden_terms.sh <run_dir>
```

Also scan generated HTML and JSON.

Expected:

- no broken encoding or mojibake
- no real credentials or key-like values
- no internal hostnames
- no private vendor account details
- no stale supplier labels in user-facing text
- no real user data in public packages

## 8. HTML QA

Open the real generated HTML. Check:

- charts render
- axes visible
- legends explain colors/lines
- tables align numeric columns
- long lists fold when appropriate
- optional sections are clearly marked
- internal terms absent
- no external runtime assets load
- mobile/narrow layout acceptable when relevant

When possible, use a browser automation smoke test:

- open `file://.../report.html`
- block network requests
- capture desktop and mobile screenshots
- check console errors
- check no horizontal overflow
- check canvas pixels or SVG/chart nodes are non-empty

## 9. Release Package

Before copying or zipping a user-facing package:

- remove development source unless this is a source repo release
- remove run outputs
- remove non-redacted user sample data
- remove duplicate nested folder layer
- keep only required binaries under `tools/bin`
- ensure macOS binaries are executable

If creating an archive, unpack it into a temp directory and verify:

```text
<tmp>/<skill_name>/SKILL.md exists
<tmp>/<skill_name>/<skill_name>/SKILL.md does not exist
```

## 10. Final Handoff

Tell the user:

- skill folder path
- whether binaries were rebuilt
- what fixture/run was used
- what checks passed
- any known limitations

Do not overclaim. If real agent testing has not happened, say so.
