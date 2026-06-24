# Artifact Pipeline

Use this file when designing run directories, trace files, HTML reports, append flows, or handoff paths for downstream skills.

## Core Principle

A mature skill should produce files, not only chat text. The standard pattern is:

```text
user input
-> inspect
-> create fresh output directory
-> write manifest
-> write cleaned/normalized JSON
-> write analysis or agent-basis JSON
-> render prebuilt HTML template from report_data.json
-> print final artifact path
```

Use `RUN_DIR` for a standalone skill that ends after one report. Use `PROJECT_ROOT` only when the requirement explicitly needs multiple skills to continue from the same project. Common reasons to split into multiple skills: the workflow is too long for one reliable agent flow, one stage produces a clean basis dataset for a later stage, or a later stage is optional and should not burden the base workflow.

## Glossary

- `RUN_DIR`: one skill run, one output surface. Example: `domain_report_YYYYMMDD_HHMMSS/`.
- `PROJECT_ROOT`: multi-stage or multi-skill project root. It must contain `project_manifest.json` and stage folders.
- `STAGE_DIR`: one stage inside `PROJECT_ROOT`, such as `stage_one/` or `stage_two/`.
- `report_data.json`: exact view model used by the HTML renderer. Required for HTML reports.

## Standalone Skill Output

Use this when one skill can complete the workflow by itself.

```text
run_YYYYMMDD_HHMMSS/
  01_input_manifest.json
  02_cleaned_data.json
  03_analysis.json
  report_data.json
  final_report.html
  auxiliary.xlsx or detail.csv
```

Rules:

- Do not write outputs into the input directory.
- Create a fresh output directory for each normal `run`.
- If the output directory exists and is not empty, fail or write into a clearly named fresh subfolder.
- Final response must show the run directory and final artifact path.
- Do not print `PROJECT_ROOT=...` unless another skill is expected to continue.

## Multi-Skill Project Output

Use this only when another skill must continue from the first skill's output. Do not split a workflow just because multiple modules exist; split when it reduces agent confusion or lets users run stage one successfully without committing to stage two.

```text
project_YYYYMMDD_HHMMSS/
  project_manifest.json
  stage_one/
    01_input_manifest.json
    02_cleaned_data.json
    03_analysis.json
    report_data.json
    report.html
  stage_two/
    01_stage_input_manifest.json
    02_agent_labels.json
    03_analysis.json
    report_data.json
    report.html
```

The producing skill's final response must include both:

```text
本次项目目录：<absolute_project_dir>
PROJECT_ROOT=<absolute_project_dir>
```

The dependent skill must:

- read only `PROJECT_ROOT` from the current conversation context
- if multiple values appear, use the most recent explicit value
- verify `project_manifest.json`
- verify the required upstream stage is `ready`
- verify referenced basis files exist under the project root
- stop if any check fails
- not scan local folders for the newest project
- not ask the user for arbitrary replacement files unless standalone mode is explicitly designed

## Manifest Contracts

### Single Run

`01_input_manifest.json` must include detected inputs, detected context, tool version, and output file names.

### Multi-Skill Project

`project_manifest.json` must use relative paths so the project can be copied:

```json
{
  "schema_version": "1.0",
  "project_id": "project_YYYYMMDD_HHMMSS",
  "root_type": "multi_skill_project",
  "created_at": "2026-06-24T12:00:00+08:00",
  "producer": {"skill": "skill_a", "version": "0.1.0"},
  "stages": {
    "stage_one": {
      "status": "ready",
      "path": "stage_one",
      "html": "stage_one/report.html",
      "report_data": "stage_one/report_data.json",
      "basis_files": ["stage_one/03_analysis.json"],
      "updated_at": "2026-06-24T12:03:00+08:00"
    },
    "stage_two": {
      "status": "pending",
      "path": "stage_two",
      "required_upstream": "stage_one"
    }
  }
}
```

Valid stage statuses:

- `pending`
- `running`
- `ready`
- `failed`
- `skipped`

Local absolute paths may be shown in chat for the user's convenience. Public/shareable JSON and HTML should use relative paths, `project_id`, or redacted path labels.

## Mandatory Trace Files

At minimum, write:

- `01_input_manifest.json`: original inputs, detected context, dates, entity IDs, versions.
- `02_*`: cleaned, normalized, supplemented, or agent workspace data.
- `03_*`: main analysis result.
- `report_data.json`: exact data object used by the HTML renderer for HTML reports.

If agent judgment is used, also write:

- `agent_workspace.json`: what the agent had to judge.
- `agent_output.json`: structured agent labels, summaries, or research.
- `validation_result.json` or CLI stdout showing coverage checks.

Do not leave important reasoning only in chat.

## CLI Stdout Status

All `inspect-*`, `run`, and `attach-*` commands should print machine-readable JSON:

```json
{
  "status": "ready",
  "message": "ready",
  "output_dir": "<run_or_project_dir>",
  "html": "<relative_or_absolute_html_path>",
  "missing_inputs": [],
  "warnings": []
}
```

Allowed statuses:

- `ready`: the next step can run or the command completed.
- `needs_confirmation`: agent/user judgment is required before continuing.
- `failed`: command cannot continue; exit non-zero.

Do not rely on prose-only stdout for agent decisions.

## Prebuilt HTML Template

The HTML template is product code.

Required flow:

1. CLI computes `AnalysisResult`.
2. CLI builds `ReportData`.
3. CLI writes `report_data.json`.
4. CLI renders a fixed template using `ReportData`.
5. Generated HTML embeds CSS, JavaScript, and data so it opens offline.

Allowed template locations:

- Go `embed` template under `go-cli/internal/report/`.
- Runtime `assets/report_template.html` only when the asset is included and path resolution is tested from the installed skill folder.

Not allowed:

- agent hand-composes final HTML in chat
- CLI assembles the whole page with ad hoc string concatenation
- calculations exist only in JavaScript without JSON basis
- external runtime assets are loaded from the network

Use `references/report-data-contract.md` for the required view-model shape.

## Data Injection Rules

Keep these separate:

- raw source data
- cleaned data
- calculation result
- display view model

Preferred Go pattern:

```text
AnalysisResult -> ReportData -> html/template -> final HTML
```

For embedded report data, JSON-escape the full object and place it inside:

```html
<script type="application/json" id="report-data">...</script>
```

Do not put unescaped user text, product titles, or public web excerpts directly into JavaScript strings.

## Optional Append Sections

Use append commands when optional enrichment updates an existing report:

```text
run
attach-external
attach-offsite
attach-annotations
```

Append commands must behave transactionally:

- read the existing run or stage directory
- validate the agent-written JSON before changing report files
- write a new numbered JSON file, such as `07_external_research.json`
- update `report_data.json`
- rewrite the same HTML
- update manifest/stage metadata if a manifest exists
- preserve the original deterministic analysis
- fail before rewriting HTML if validation fails

Duplicate append input should either be idempotent or create a clearly numbered new section. Optional weak evidence cannot overwrite core metrics.

Use `attach-*` for updating an existing stage/report. For separate downstream skills, create or update a separate `STAGE_DIR` under `PROJECT_ROOT` instead of treating cross-skill continuation as an attach flow.

## Blocking / Stop Conditions

A continuation skill must stop when:

- no `PROJECT_ROOT` exists in the current conversation
- more than one `PROJECT_ROOT` exists and no most-recent explicit value is clear
- project path is inaccessible
- `project_manifest.json` is missing or invalid
- required upstream stage is not `ready`
- required basis files are missing
- target stage already contains non-empty incompatible output
- standalone mode is not part of the requirement

Stop with a short explanation and do not search the filesystem for substitutes.

## Final Response Contract

A standalone skill must tell the user:

- run directory
- final HTML or artifact path
- key basis files
- optional next step only when relevant

A producing skill in a multi-skill workflow must additionally print `PROJECT_ROOT=<absolute_project_dir>`.

Avoid vague wording such as "文件已经生成好了" without a path.

## HTML Regeneration Rule

After changing a template, renderer, chart, or display label:

```bash
go test ./...
./build.sh
<cli> run ... --output <fresh_run_dir>
```

For optional sections:

```bash
<cli> attach-... --output-dir <existing_run_dir> --research-json <json>
```

Always inspect the real generated HTML, not just the template source.

## What Must Not Happen

- Single-skill workflows forced into `PROJECT_ROOT` without downstream need.
- HTML generated only by agent chat text.
- No manifest or input record.
- No cleaned/basis data file.
- Optional evidence mixed into core metrics without trace.
- Downstream skill guessing the wrong previous run.
- Final answer omitting the run/project path.
