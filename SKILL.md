---
name: agent-meta-skill
description: Design, implement, package, and validate production-ready Agent skills from a requirement brief, rough workflow, sample artifact, or old script. Use when creating a new skill, refactoring an existing skill into agent + deterministic CLI + optional remote capability layers, writing SKILL/INSTRUCTIONS/AGENTS/reference docs, packaging a Go CLI into four platform binaries, designing offline HTML reports, or preparing a skill for public/open-source handoff without exposing private auth, billing, vendor, token, or infrastructure details.
---

# Agent Meta-Skill

Use this skill to turn a business workflow into a clean, testable, portable Agent skill. The expected result is not just a prompt: it is a skill folder with agent instructions, deterministic tools, clear contracts, cross-platform packaging, offline artifacts, and repeatable QA.

Start by reading `INSTRUCTIONS.md`; use the references below only when the current design step needs them.

## Core Workflow

1. Read the requirement brief, sample files, prior run logs, and any existing skill folders. Do not implement from memory.
2. Decide the architecture using `references/architecture.md`: agent layer, local CLI layer, optional remote capability layer, and final artifact layer.
3. If this is the first implementation, follow `references/first-build-walkthrough.md` before coding.
4. Design the run/project directory, trace JSON files, HTML data contract, and multi-skill handoff using `references/artifact-pipeline.md`.
5. Create or normalize the skill layout using `references/file-layout.md`.
6. Write the agent-facing docs using `references/agent-docs.md`. Keep user-facing flow simple; hide private implementation details.
7. Implement deterministic work in a local CLI. Prefer Go when the skill needs cross-platform distribution; use `references/go-cli-packaging.md`.
8. Design the final report or output surface with `references/html-report-design.md` when the skill produces an HTML artifact.
9. If the skill needs online or account-backed data, read `references/remote-capability-boundary.md` before writing any docs, config names, errors, or HTML labels.
10. Run the checks in `references/qa-release-checklist.md`. Use real agent testing, not only direct CLI testing.
11. If a new failure mode is found, record it in the new skill's handoff notes. Update this meta-skill's `references/pitfalls.md` only when the user is explicitly maintaining this meta-skill.

## Required vs Optional

Required for a productized skill:

- `SKILL.md`: trigger description and high-level navigation.
- `INSTRUCTIONS.md`: exact execution procedure for the agent.
- `references/`: contracts, formulas, schemas, and optional follow-up flows.
- `tools/bin/`: runnable user-facing tools if deterministic execution is needed.
- A local fixture or real run directory for validation; do not ship user data or run outputs in the public skill package.
- A release check that scans for private terms, secrets, broken encoding, and stale binaries.

Recommended:

- `AGENTS.md`: concise agent entrypoint for contexts that read it.
- `go-cli/`: source for deterministic Go CLI in the development repo.
- `build.sh`: reproducible four-platform build script.
- `scripts/check_forbidden_terms.sh`: public-safety scan.
- `scripts/check_skill_package.sh`: package-shape scan.

Optional:

- `assets/`: templates, icons, embedded front-end assets, or static fixtures used by the output.
- `attach-*` CLI commands for optional second-stage enrichment.
- Remote capability adapters, only when local files are insufficient.

## Output Standard

A finished skill should be easy for another agent to use without asking the user unnecessary questions. Prefer this command shape:

```text
<cli> inspect-inputs <input>
<cli> run <input> --output <run_dir>
<cli> attach-optional-feature --output-dir <run_dir> --research-json <json>
```

The first run must create a dedicated run/project directory and print the final artifact path. If a later skill depends on that directory, the producing skill must include both lines in the final response:

```text
本次项目目录：<absolute_project_dir>
PROJECT_ROOT=<absolute_project_dir>
```

Any dependent skill must read only `PROJECT_ROOT` from the current conversation context, verify `project_manifest.json`, and stop if it is absent or invalid. It must not scan local folders, choose a "latest" project, or ask the user for arbitrary replacement files unless standalone mode is explicitly designed.

## References

- `references/architecture.md`: how to split agent, CLI, remote, and artifact responsibilities.
- `references/first-build-walkthrough.md`: minimal first implementation path from rough requirement to tested skill.
- `references/file-layout.md`: required folder structure and public package shape.
- `references/agent-docs.md`: how to write SKILL.md, INSTRUCTIONS.md, AGENTS.md, and contracts.
- `references/go-cli-packaging.md`: Go CLI conventions, four-platform build, macOS xattr, and bin hygiene.
- `references/artifact-pipeline.md`: run directory, JSON trace, prebuilt HTML templates, and multi-skill handoff paths.
- `references/report-data-contract.md`: required `report_data.json` view-model shape for offline HTML reports.
- `references/html-report-design.md`: offline report design and chart/report rules.
- `references/remote-capability-boundary.md`: how to describe remote capabilities without exposing private implementation.
- `references/qa-release-checklist.md`: validation commands and real-agent test gates.
- `references/pitfalls.md`: known failure modes from real skill development.

## Scripts

- `scripts/check_forbidden_terms.sh <skill_dir>` scans docs and HTML for terms that should not appear in a public-facing skill.
- `scripts/check_skill_package.sh <skill_dir> [cli-prefix]` checks required docs and the expected four binary files under `tools/bin/`.
- `scripts/check_run_artifact.sh <run_or_project_dir>` checks generated JSON/HTML artifacts for parse errors, mojibake, missing report data, and external runtime assets.
