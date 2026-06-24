# File Layout

Use this file when creating or reviewing the folder structure for a new skill.

## Development Repository Layout

Recommended neutral layout:

```text
skill-projects/<domain>/
  docs/
    requirements.md
    examples/
  go-cli/
    go.mod
    *.go
    build.sh
  <skill_name>/
    SKILL.md
    INSTRUCTIONS.md
    AGENTS.md
    references/
    tools/
      bin/
```

The development repo may contain `go-cli/`, sample run directories, docs, and examples. The user-facing skill folder should stay clean.

In this repository you may use the local convention `skills_dev3/<NN-domain>/`, but do not hard-code that local path into open-source instructions.

When a requirement document is supplied under `<domain>/docs/`, create the new skill under that `<domain>/` project. Do not create business skills inside this meta-skill folder.

## Distribution Boundaries

Classify every file into one of these surfaces before release.

| Surface | Who uses it | What belongs here | What must not be here |
| --- | --- | --- | --- |
| Agent-facing skill package | The installed agent at runtime | `SKILL.md`, `INSTRUCTIONS.md`, `AGENTS.md`, `references/`, `tools/bin/`, runtime `assets/`, public-safe `config.json` | Go source, requirement drafts, real fixtures, run outputs, private connection details |
| Development source repo | Skill builders and maintainers | `docs/`, requirements, examples, `go-cli/`, tests, build scripts, synthetic fixtures, local validation notes | Real secrets, unredacted user data intended for public release |
| Remote capability deployment | Private operator/deployer | backend code, private routing, upstream account setup, operational configuration | public agent docs, user-facing HTML wording, open-source package contents |
| Generated run/project output | End user and downstream skills | `RUN_DIR` or `PROJECT_ROOT`, manifests, trace JSON, `report_data.json`, HTML, CSV/XLSX | source code, package files, private deployment configuration |

Rules:

- Do not copy the development repo as the user-facing skill package.
- Do not put remote deployment configuration into the public skill package.
- Do not put generated run directories into the skill package.
- Do not make the agent ask users for remote capability setup; the CLI should either succeed through configured capability or fail with a public-safe error.
- If a skill is open-sourced, keep source/build materials in the source repo and create a separate runtime package when distributing to users.

## User-Facing Skill Folder

Required:

```text
<skill_name>/
  SKILL.md
  INSTRUCTIONS.md
  references/
  tools/
    bin/
```

Recommended:

```text
<skill_name>/
  AGENTS.md
```

Optional:

```text
<skill_name>/
  assets/
  agents/
  config.json
```

Use `config.json` only for public-safe local configuration names. Never commit real secrets into an open-source skill.

## Required Markdown Roles

### SKILL.md

Must contain:

- YAML frontmatter with `name` and `description`.
- A concise overview.
- The shortest correct usage route.
- Which reference files to read and when.
- Tool/binary locations.

Must not contain:

- Long requirement copies.
- Internal auth/infra/billing details.
- Token names or private service URLs.
- Large schemas that belong in references.

### INSTRUCTIONS.md

Must contain:

- Fixed opening question if user input is missing.
- Exact input contract summary.
- Platform CLI selection.
- macOS first-run commands if binaries are shipped.
- Step-by-step CLI sequence.
- What to do on `ready`, `needs_confirmation`, and `failed`.
- Final response requirements.
- Optional append/enrichment flow if supported.

### AGENTS.md

Recommended as a compact entrypoint:

- One paragraph summary.
- Key boundaries.
- CLI list.
- First commands to run.

It should be shorter than `INSTRUCTIONS.md`.

### references/

Use references for:

- Input contracts.
- Calculation specs.
- Agent JSON output contracts.
- Optional external research contracts.
- Report interpretation boundaries.
- Remote capability boundaries.

## Public Package Shape

For a distributable skill package, keep only what the runtime agent needs:

```text
<skill_name>/
  SKILL.md
  INSTRUCTIONS.md
  AGENTS.md
  agents/openai.yaml  # optional UI metadata
  references/
  tools/bin/<four binaries>
  assets/            # only if used
  config.json        # only if public-safe
  scripts/           # only for documented runtime checks/helpers
```

Do not include:

- `go-cli/`
- `cli-src/`
- temporary run directories
- sample user data
- non-redacted real user fixtures
- `.env`
- old binary names
- nested duplicated top-level folders
- generated debug logs
- archives such as `.zip` or `.tar.gz`

Open-source development repos may include source, tests, and synthetic fixtures. Runtime skill packages should contain only what the installed agent needs.

## Run Directory Shape

A mature analytical skill should create a dedicated run directory:

```text
run_name_YYYYMMDD_HHMMSS/
  01_input_manifest.json
  02_cleaning_or_supplement.json
  03_analysis.json
  report.html
  detail.csv
  auxiliary.xlsx
```

Use numbered JSON files so later agents can locate the basis quickly.

For a multi-skill project, use a project root:

```text
project_YYYYMMDD_HHMMSS/
  project_manifest.json
  stage_one/
  stage_two/
```

Only use this when a downstream skill must continue. Standalone skills should not invent `PROJECT_ROOT`.

## Naming Rules

- Skill folder: lowercase letters, digits, and underscores or hyphens matching the existing repo style.
- CLI binary prefix: short and domain-specific.
- Run directory: `<domain>_YYYYMMDD_HHMMSS`.
- HTML: user-facing Chinese title if the target users are Chinese.

## Hygiene Checks

Before handoff:

```bash
find <skill_name>/tools/bin -maxdepth 1 -type f -exec basename {} \; | sort
```

For Go-based skills, `tools/bin/` should normally contain exactly four binaries.

Use the meta-skill checker for stricter package validation:

```bash
<meta-skill>/scripts/check_skill_package.sh <skill_name> <cli-prefix>
```
