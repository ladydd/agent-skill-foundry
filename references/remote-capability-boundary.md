# Remote Capability Boundary

Use this file before adding any online, account-backed, paid, or private capability to a public-facing skill.

## Purpose

A skill may need data that local files cannot provide. Public skill docs should describe the capability outcome, not private infrastructure, account setup, billing, credentials, or upstream vendor details.

## Public Terms

Use neutral labels:

- `automatic supplemental data`
- `remote enrichment capability`
- `configured capability`
- `keyword root capability`
- `public web evidence`

Chinese equivalents:

- `自动补充数据`
- `远程补充能力`
- `已配置能力`
- `词根能力`
- `公开网页证据`

Prefer "capability" over "service" unless the word is part of visible product UX.

## Forbidden in Public Docs and HTML

Do not expose:

- real credentials or secret-looking values
- private auth, quota, accounting, or routing implementation
- private hostnames or server filesystem paths
- upstream vendor account details
- raw upstream API brand names unless the user-facing product explicitly depends on that brand
- credential field names or setup labels that teach users how private deployment is wired
- personal project nicknames

## Agent Instructions

Agent-facing docs should say:

```text
The CLI automatically obtains supplemental data. The agent does not ask the user for credentials, account details, or capability configuration.
```

Do not include private setup variable names or upstream vendor implementation in `SKILL.md`, `INSTRUCTIONS.md`, HTML labels, or public errors.

## Public CLI Contract

The CLI may expose request status and counts, but not private configuration.

Request command shape:

```text
<cli> fetch-supplemental --report-dir <dir> --output-dir <dir>
```

Success stdout:

```json
{
  "status": "ready",
  "message": "supplemental data ready",
  "request_count": 1,
  "output": "stage/02_supplemental_data.json",
  "warnings": []
}
```

Failure stdout:

```json
{
  "status": "failed",
  "message": "Automatic supplemental data request failed.",
  "warnings": ["Retry later or continue only if the requirement permits missing supplemental data."]
}
```

Safe fields for supplemental JSON:

```json
{
  "schema_version": "1.0",
  "source_label": "automatic supplemental data",
  "as_of": "2026-06-24T12:00:00+08:00",
  "request_count": 1,
  "items": [],
  "warnings": []
}
```

## Config Files

Open-source packages should not contain private connection configuration or credential-shaped field names. If private deployment needs configuration, keep it outside the public package as a private overlay managed by the deployer.

Public-safe `config.json` may contain only non-sensitive runtime preferences, such as:

```json
{
  "locale": "zh-CN",
  "default_output_name": "report"
}
```

## Accounting and Quota Wording

Do not document private accounting or quota mechanics in public agent docs. The agent only needs to know whether the CLI succeeded, failed, or returned a request count.

Safe wording:

```text
If the CLI returns request_count, report it as an execution detail. Do not infer billing from it.
```

## Public Web Research

Public web research is different from private remote enrichment. It may be agent-driven when the task needs browsing, but must keep evidence boundaries:

- public pages only
- no private groups or login-required pages
- cite source URLs in JSON/CSV
- separate evidence from conclusions
- never treat weak public snippets as due diligence
