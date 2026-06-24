# Go CLI Packaging

Use this file when the skill needs deterministic local execution or cross-platform distribution.

## Why Go

Prefer Go for user-facing CLI tools when:

- The skill must run on Windows, macOS, and Linux.
- The workflow should not depend on the user's Python environment.
- The tool parses files, computes metrics, validates JSON, or generates HTML.
- The final skill package should contain simple binaries under `tools/bin/`.

Python can remain useful for prototypes, but a production user package should avoid fragile module paths and missing dependency issues.

## Source Layout

Recommended development layout:

```text
<skill_project>/
  go-cli/
    go.mod
    main.go
    ...
    build.sh
  <skill_folder>/
    tools/
      bin/
```

`go-cli/` belongs in the development repo. The user-facing skill uses the compiled binaries in `tools/bin/`.

## Binary Names

Use exactly four binaries for a standard Go skill:

```text
tools/bin/<cli-prefix>-linux-amd64
tools/bin/<cli-prefix>-darwin-amd64
tools/bin/<cli-prefix>-darwin-arm64
tools/bin/<cli-prefix>-windows-amd64.exe
```

Do not leave extra binaries, debug executables, old `.cmd` wrappers, or source folders in `tools/bin/`.

## build.sh Template

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/<skill_folder>/tools/bin"
TMP="$OUT/.tmp-build"

mkdir -p "$OUT"
rm -rf "$TMP"
mkdir -p "$TMP"
cd "$ROOT/go-cli"

CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags='-s -w' -o "$TMP/<cli-prefix>-linux-amd64" .
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -trimpath -ldflags='-s -w' -o "$TMP/<cli-prefix>-windows-amd64.exe" .
CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -trimpath -ldflags='-s -w' -o "$TMP/<cli-prefix>-darwin-amd64" .
CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -trimpath -ldflags='-s -w' -o "$TMP/<cli-prefix>-darwin-arm64" .

rm -f "$OUT/<cli-prefix>-linux-amd64" \
  "$OUT/<cli-prefix>-darwin-amd64" \
  "$OUT/<cli-prefix>-darwin-arm64" \
  "$OUT/<cli-prefix>-windows-amd64.exe"
mv "$TMP"/* "$OUT/"
rmdir "$TMP"

actual="$(find "$OUT" -maxdepth 1 -type f -exec basename {} \; | sort | tr '\n' ' ')"
expected="<cli-prefix>-darwin-amd64 <cli-prefix>-darwin-arm64 <cli-prefix>-linux-amd64 <cli-prefix>-windows-amd64.exe "
if [[ "$actual" != "$expected" ]]; then
  echo "unexpected tools/bin contents: $actual" >&2
  exit 1
fi
```

Run:

```bash
cd <skill_project>/go-cli
go test ./...
./build.sh
```

## Platform Selection in INSTRUCTIONS.md

Include a platform table:

```text
Windows x64: .\tools\bin\<cli-prefix>-windows-amd64.exe
Linux x64:   ./tools/bin/<cli-prefix>-linux-amd64
macOS Intel: ./tools/bin/<cli-prefix>-darwin-amd64
macOS M 系:  ./tools/bin/<cli-prefix>-darwin-arm64
```

For macOS first run, include:

```bash
xattr -dr com.apple.quarantine ./tools/bin 2>/dev/null || true
chmod +x ./tools/bin/<cli-prefix>-darwin-amd64 ./tools/bin/<cli-prefix>-darwin-arm64 2>/dev/null || true
```

Use this single whole-folder quarantine removal pattern; do not document multiple competing macOS first-run approaches.

## Platform Detection Snippet

When an agent needs to choose a binary itself:

```bash
os="$(uname -s 2>/dev/null | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m 2>/dev/null)"
case "$arch" in
  x86_64|amd64) arch="amd64" ;;
  arm64|aarch64) arch="arm64" ;;
esac
case "$os/$arch" in
  linux/amd64) cli="./tools/bin/<cli-prefix>-linux-amd64" ;;
  darwin/amd64) cli="./tools/bin/<cli-prefix>-darwin-amd64" ;;
  darwin/arm64) cli="./tools/bin/<cli-prefix>-darwin-arm64" ;;
  *) echo "Unsupported platform: $os/$arch" >&2; exit 1 ;;
esac
```

For Windows, use the `.exe` binary from PowerShell:

```powershell
.\tools\bin\<cli-prefix>-windows-amd64.exe
```

## CLI Commands

Prefer subcommands:

```text
inspect-inputs
inspect-report
run
fetch-...
attach-...
```

Print JSON to stdout for machine-readable success:

```json
{
  "ok": true,
  "output_dir": "...",
  "html": "...",
  "event_count": 7
}
```

Return non-zero with a direct error when blocked.

## Validation Gates

After build:

```bash
find <skill_folder>/tools/bin -maxdepth 1 -type f -exec basename {} \; | sort
file <skill_folder>/tools/bin/*
```

Expected:

- exactly four direct files for a standard Go CLI package
- Linux amd64 ELF
- macOS Mach-O x86_64 and arm64
- Windows PE32+ x86-64
- Linux/macOS binaries have executable bits

Run the meta-skill package check as the canonical gate:

```bash
<meta-skill>/scripts/check_skill_package.sh <skill_folder> <cli-prefix>
```

## Common Go CLI Responsibilities

The CLI should:

- parse and validate inputs
- generate manifests
- write basis JSON
- calculate deterministic metrics
- validate agent-written JSON
- standardize labels and summaries
- render HTML
- scan or reject encoding damage

The CLI should not:

- expose private tokens in errors
- require the user to install language dependencies
- silently continue after missing required remote configuration when the report would be incomplete
- create different outputs for the same input without a reason

## Shipping Source vs Package

Open-source development repo may include `go-cli/`, build scripts, tests, license, checksums, and provenance notes.

End-user skill package should usually include only:

```text
SKILL.md
INSTRUCTIONS.md
AGENTS.md
references/
tools/bin/<four binaries>
assets/ if used
```
