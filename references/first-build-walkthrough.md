# First Build Walkthrough

Use this when starting a new skill from a requirement brief, old script, sample files, or rough workflow. The goal is a minimal complete skill before polishing: agent docs, deterministic CLI, trace files, HTML if needed, and a real run.

## Minimal Path

1. Create the domain project outside this meta-skill:

```text
<domain_project>/
  docs/
    requirements.md
    examples/
  go-cli/
  <skill_name>/
```

If the requirement document already lives under `<domain_project>/docs/`, use that parent as the project root. Do not create the new business skill inside `agent-meta-skill/`.

2. Extract the requirement into a one-page implementation note:

```text
User input:
Final artifact:
Deterministic calculations:
Agent judgments:
Remote supplemental capability:
Multi-skill dependency:
Stop conditions:
```

3. Decide the runtime shape:

| Shape | Use when | Required runtime files |
| --- | --- | --- |
| docs-only | the agent only needs a fixed procedure and no parsing/calculation | `SKILL.md`, `INSTRUCTIONS.md`, `references/` |
| script-backed | deterministic helper is small and environment is controlled | docs plus `scripts/` or a documented helper |
| Go CLI | user-facing parsing, calculation, validation, HTML, or cross-platform execution | docs plus `tools/bin/<four binaries>` |
| remote-backed | local files are insufficient and configured supplemental data is required | docs, local CLI, public-safe remote wording |

4. Build the first CLI skeleton before polishing prompts:

```text
<cli> inspect-inputs <input>
<cli> run <input> --output <fresh_dir>
```

`inspect-*` should report `status`, detected context, missing inputs, and warnings. `run` should create a fresh output directory, write JSON traces, and render final artifacts.

5. Create the first run directory contract:

```text
<run_or_project_dir>/
  project_manifest.json or 01_input_manifest.json
  02_cleaned_or_workspace.json
  03_analysis.json
  report_data.json       # required for HTML reports
  <final_report>.html    # if HTML is the artifact
```

6. Write agent docs only after the CLI and artifact contract are known:

- `SKILL.md`: trigger, shortest route, required references.
- `INSTRUCTIONS.md`: exact opening, CLI selection, commands, stop behavior, final response.
- Reference contracts: input, calculation, agent JSON, optional public web research.

7. Run a real fixture through the installed skill, not only the CLI. Save enough evidence to reproduce: prompt, skill path, selected binary, output directory, final artifact path, and observed failures.

## Definition of Done

A first version is not done until:

- `quick_validate.py` passes, or missing validator is explicitly recorded.
- the deterministic CLI runs on a fixture and writes trace JSON.
- HTML reports are rendered from `report_data.json`, not hand-composed by the agent.
- Go skills ship exactly four platform binaries in `tools/bin/`.
- macOS first-run commands are present when Darwin binaries ship.
- `PROJECT_ROOT=...` is printed when another skill must continue.
- a fresh-agent test confirms the agent asks only for necessary input and stops on missing prerequisites.
- public package scans show no private credentials, internal hosts, user data, mojibake, or extra binary clutter.
