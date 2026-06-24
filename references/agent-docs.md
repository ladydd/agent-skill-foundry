# Agent-Facing Documentation

Use this file when writing `SKILL.md`, `INSTRUCTIONS.md`, `AGENTS.md`, or reference contracts.

## Writing Principles

- Write for a capable agent, not a human beginner.
- Make the happy path explicit.
- Put fragile rules in exact commands or schemas.
- Keep private implementation details out.
- Do not describe internal debugging history.
- Do not include multiple competing ways to do the same step unless the agent must choose by platform or mode.

## SKILL.md Pattern

Required frontmatter:

```yaml
---
name: skill_name
description: What this skill does and exactly when to use it...
---
```

The description must include trigger conditions because it is loaded before the body.

For continuation skills, the description must also state the upstream context requirement:

```yaml
description: Continue from a prior <stage> project only when the current conversation contains PROJECT_ROOT=<path> or an explicit upstream project directory...
```

Body pattern:

```markdown
# Skill Title

One short paragraph.

## 使用方式

1. Read `INSTRUCTIONS.md`.
2. Ask for the minimum input.
3. Run `<cli> inspect-*`.
4. Run `<cli> run`.
5. If user explicitly continues optional work, read the specific reference and run `attach-*`.

## 资源

- `references/input_contract.md`: ...
- `references/calculation_spec.md`: ...
- `tools/bin/`: ...
```

## INSTRUCTIONS.md Pattern

Recommended sections:

```markdown
# <Skill> 指令

## 你的角色
## 固定开场
## 输入要求
## CLI 选择
## 步骤 1：识别输入
## 步骤 2：生成报告
## 可选步骤：追加...
## 数据和判断边界
```

The fixed opening should ask for the smallest input. If the CLI can infer market, keyword, entity ID, category, or date, do not ask the user to provide them.

## Continuation Skill Pattern

Use this only when a requirement is intentionally split into multiple skills because the workflow is too long, optional, or stage two depends on stage one outputs.

`SKILL.md` description must say:

```text
Use only when the current conversation contains PROJECT_ROOT=<path> or an explicit upstream project directory from <upstream skill>.
```

`INSTRUCTIONS.md` fixed opening must say:

```text
This skill continues from the previous project. First read PROJECT_ROOT from the current conversation. If PROJECT_ROOT is absent, inaccessible, or lacks a valid project_manifest.json with the required upstream stage ready, stop and explain that the upstream skill must be run first.
```

Continuation skill rules:

- Do not scan local folders for newest or latest projects.
- Do not ask the user for arbitrary replacement files.
- Do not continue from a raw run directory unless the requirement explicitly supports standalone mode.
- If multiple `PROJECT_ROOT` values appear, use the most recent explicit one.
- Verify manifest paths stay under the project root.
- Write stage outputs under a dedicated stage folder and update `project_manifest.json`.

## AGENTS.md Pattern

Keep it short:

```markdown
# Agent 入口

完整指令请阅读 `INSTRUCTIONS.md`.

## 概要

...

## 关键边界

- ...

## 工具

- ...

## 优先动作

...
```

## Reference Contract Pattern

Use references for details that should be loaded only when needed.

Examples:

- `input_contract.md`: file names, required columns, inspect behavior.
- `calculation_spec.md`: formulas, filters, confidence rules.
- `agent_workflow.md`: agent judgment schema and boundaries.
- `external_research_contract.md`: browsing scope and JSON schema.
- `remote_capability_contract.md`: public-safe wording for remote enrichment.

Contracts should include:

- Required fields.
- Optional fields.
- Valid enum values.
- Example JSON.
- Validation rules.
- What the agent must not infer.

Minimal examples should be copyable. For a data-backed skill, include at least:

```json
{
  "status": "ready",
  "detected": {"marketplace": "US", "keyword": "example"},
  "missing_inputs": [],
  "warnings": []
}
```

For agent judgment, include both workspace and output shapes:

```json
{
  "items": [
    {"id": "A1", "title": "source text", "fields_available": ["title", "params"]}
  ],
  "required_labels": ["related", "irrelevant", "uncertain"]
}
```

```json
{
  "labels": [
    {"id": "A1", "label": "related", "reason_code": "core_market", "evidence": "title matches"}
  ]
}
```

## Must / Should / Optional Language

Use:

- `must` / `必须`: correctness or safety requirement.
- `should` / `建议`: strong default with room for exceptions.
- `optional` / `可选`: only when explicitly useful.

Avoid vague phrases:

- "看情况"
- "大概"
- "尽量"
- "可以自己判断" without a schema or boundary.

## Secrets and Private Terms

Public-facing docs must not mention:

- real tokens, keys, passwords, app secrets
- private auth or billing implementation
- internal hostnames or server paths
- vendor account details
- private credential names or equivalent secret labels
- private project nicknames that would confuse open-source users

Use generic terms:

- `remote supplemental capability`
- `automatic enrichment`
- `configured capability`
- `public web evidence`

## Encoding Rules

If the agent writes JSON containing Chinese text:

- Use UTF-8 file writing.
- Do not write Chinese JSON through PowerShell here-strings, `echo`, or default `Out-File`.
- After writing, parse JSON and scan for `???`.

Bad:

```powershell
@' ... 中文 JSON ... '@ | node -
```

Good:

- Use the editor/apply patch.
- Use a UTF-8 script file.
- Use a CLI command that writes JSON itself.

## Final Response Rules

The agent should report:

- output directory
- final artifact path
- key counts
- optional next step only when relevant

The agent should not paste long JSON or long tables into chat when files were generated.

For multi-skill handoff, the producing agent must include:

```text
本次项目目录：<absolute_project_dir>
PROJECT_ROOT=<absolute_project_dir>
```
