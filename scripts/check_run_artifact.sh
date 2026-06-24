#!/usr/bin/env bash
set -euo pipefail

target="${1:-}"
if [[ -z "$target" || ! -d "$target" ]]; then
  echo "usage: $0 <run_or_project_dir>" >&2
  exit 2
fi

fail=0
say_fail() {
  echo "$*" >&2
  fail=1
}

json_count=0
while IFS= read -r -d '' json_file; do
  json_count=$((json_count + 1))
  python3 - "$json_file" <<'PY' || fail=1
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
data = path.read_bytes()
try:
    text = data.decode("utf-8-sig")
except UnicodeDecodeError as exc:
    print(f"invalid utf-8 JSON: {path}: {exc}", file=sys.stderr)
    sys.exit(1)
try:
    json.loads(text)
except Exception as exc:
    print(f"invalid JSON: {path}: {exc}", file=sys.stderr)
    sys.exit(1)
bad = ["???", "\ufffd", "Ã", "Â", "ä¸"]
if any(x in text for x in bad):
    print(f"encoding damage in JSON: {path}", file=sys.stderr)
    sys.exit(1)
PY
done < <(find "$target" -type f -name '*.json' -print0)

if [[ "$json_count" -eq 0 ]]; then
  say_fail "no JSON trace files found"
fi

html_count=0
while IFS= read -r -d '' html_file; do
  html_count=$((html_count + 1))
  if LC_ALL=C grep -q $'\357\277\275' "$html_file"; then
    say_fail "encoding replacement character in HTML: $html_file"
  fi
  if grep -Eq '\?\?\?|Ã|Â|ä¸' "$html_file"; then
    say_fail "encoding damage in HTML: $html_file"
  fi
  if grep -Eiq '<(script|link|img|iframe|source)[^>]+(src|href)=["'\'']https?://' "$html_file"; then
    grep -Ein '<(script|link|img|iframe|source)[^>]+(src|href)=["'\'']https?://' "$html_file" >&2
    say_fail "HTML loads external runtime assets: $html_file"
  fi
done < <(find "$target" -type f \( -name '*.html' -o -name '*.htm' \) -print0)

if [[ "$html_count" -gt 0 ]]; then
  if ! find "$target" -type f -name 'report_data.json' -print -quit | grep -q .; then
    say_fail "HTML artifact exists but report_data.json is missing"
  fi
fi

if [[ "$fail" != "0" ]]; then
  exit 1
fi

echo "ok: run artifact looks valid"
