# Skill Architecture

Use this file when turning a requirement brief or rough workflow into a concrete skill design.

## Default Layers

### 1. Agent Layer

The agent should:

- Ask for the minimum user input.
- Read `SKILL.md`, then `INSTRUCTIONS.md`, then only the necessary references.
- Choose the correct platform binary.
- Run CLI commands in the fixed sequence.
- Perform semantic judgment only where deterministic code cannot.
- Write structured intermediate JSON when judgment is needed.
- Summarize final artifacts and paths.

The agent should not:

- Recalculate core metrics by hand.
- Guess missing files when the CLI can inspect them.
- Ask for hidden configuration, credentials, account IDs, or internal service details.
- Write final HTML by hand when the CLI owns the report.

### 2. Local CLI Layer

The CLI should own deterministic behavior:

- Input discovery and validation.
- File parsing, cleaning, filtering, calculations, and scoring.
- JSON/CSV/XLSX output generation.
- Single-file HTML generation.
- Standardized labels and summaries.
- Guardrails against malformed JSON, encoding damage, and missing inputs.

Recommended command pattern:

```text
inspect-inputs
run
attach-<optional-section>
```

Use `inspect-*` before `run` whenever the input can be incomplete or ambiguous.

### 3. Optional Remote Capability Layer

Use a remote capability only when local files cannot reliably provide the required data. Keep it behind the CLI or a thin backend adapter. Public skill docs should describe it generically, for example:

```text
automatic supplemental data
remote enrichment capability
keyword root capability
```

Do not expose private auth, billing, vendor names, token names, internal URLs, or server topology in public-facing docs or HTML.

### 4. Artifact Layer

The final artifact should be directly usable. For analytical skills, prefer:

- Dedicated run directory.
- Single offline HTML report.
- JSON basis files.
- CSV/XLSX detail files when users need audit trails.

Do not require a local web server unless the product explicitly needs interactivity that cannot work in a file URL.

## Architecture Decision Rules

- If a step must be consistent across users, put it in the CLI.
- If a step requires judgment from titles, images, public webpages, or messy text, let the agent create structured JSON, then validate and render it through the CLI.
- If a step touches private infrastructure or paid data, hide it behind the CLI/backend and describe it as supplemental capability.
- If a later skill depends on an earlier skill, require the earlier skill to print `PROJECT_ROOT=...` and require the later skill to use that explicit context only.
- If the user can provide a prepared local file instead of an online fetch, prefer local file input.

## Continuation Skills

Some skills are not standalone. For example, a second-stage analysis skill may depend on a first-stage report directory. In that case:

- The trigger description must say it only runs when the current context contains the prior project directory.
- If the context lacks the directory, stop instead of asking the user to browse for arbitrary files.
- Do not scan local folders and pick the newest run; that causes wrong-project bugs.

## Optional Append Flow

Use `attach-*` when a report has a stable first stage and optional second-stage work:

```text
run -> base HTML
attach-external -> update same HTML
attach-offsite -> update same HTML
```

The append command should:

- Read the prior analysis JSON.
- Validate the agent-written JSON.
- Standardize labels and summaries.
- Rewrite the same HTML.
- Emit a JSON/CSV audit file.
