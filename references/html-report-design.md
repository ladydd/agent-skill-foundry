# HTML Report Design

Use this file when a skill produces a report, dashboard, or review surface.

## Default Artifact

Prefer a single offline HTML file:

- Can be opened by double-click.
- Does not require a local server.
- Embeds CSS and JavaScript.
- Reads no external network assets.
- Keeps the report portable for Windows/macOS/Linux users.

Read `artifact-pipeline.md` before implementing the renderer. The HTML should be filled from structured JSON or a typed view model, not manually assembled by the agent.

HTML reports must generate `report_data.json`; see `report-data-contract.md`. The generated HTML should be reproducible from trace JSON plus the renderer.

## Report Structure

Use a predictable structure:

```text
Hero / report title
Summary cards
Key conclusions
Main charts
Per-item panels
Detailed tables
Appendix / trace basis
```

For multi-entity or multi-item reports, use tabs/cards to switch items instead of expanding everything at once.

## Data First

Do not build visuals that are disconnected from the calculation basis. Each chart should map to fields in JSON/CSV/XLSX outputs.

Recommended data flow:

```text
source files -> cleaned JSON -> analysis JSON -> report_data/view model -> HTML
```

Do not let display labels mutate calculations. If a label, color, table order, or chart grouping changes, regenerate HTML from `report_data.json` or regenerate `report_data.json` from analysis; do not patch the final HTML by hand except for temporary visual debugging.

Good chart candidates:

- time series
- stacked or grouped bars
- two-bar plus line charts
- scatter/bubble charts for supply vs demand
- heat tables
- event rails

Avoid decorative charts that do not answer a user question.

## Explanation Standard

Every non-obvious metric needs a short explanation near the chart or table. Keep it operational:

```text
指数越高，表示目标占比相对基准占比更强。
```

Do not bury important explanations in long footnotes.

## Tables

Tables should:

- align numeric columns right
- keep headers short
- avoid cryptic labels
- use chips/badges for categories
- fold long detail lists behind `details` or a button
- not force every row to become tall because one row has many details

If a row contains many related actions, show a count by default:

```text
展开 8 条站内动作
```

## Optional Sections

If a report supports optional enrichment:

- Keep the base report valid without it.
- Append the optional section into the same HTML.
- Mark public evidence and confidence clearly.
- Keep optional evidence from overriding structured data.

Optional sections should append to `optional_sections` in `report_data.json` or a clearly numbered optional JSON file, then re-render the same HTML.

## Visual QA

Check generated HTML for:

- broken encoding (`???`)
- internal/private terms
- table overlap
- cropped date labels
- missing axes or legends
- mobile/desktop readability
- file size that is still practical

Use real generated data. A template screenshot with toy data is not enough.

When practical, add an automated smoke check:

- open the generated HTML from `file://`
- block network requests
- capture desktop and mobile screenshots
- assert console errors are zero
- assert there is no horizontal overflow
- assert expected chart titles, axes, legends, and table headers exist
- assert canvas/SVG/chart containers are non-empty

Always run `scripts/check_run_artifact.sh <run_dir>` or an equivalent project-specific artifact checker before release.

## Public Wording

Use user-facing terms:

- `自动补充数据`
- `公开网页证据`
- `站内动作`
- `样本期`
- `低置信线索`

Avoid internal terms:

- private backend names
- vendor account names
- token or key names
- internal hostnames
- implementation nicknames
