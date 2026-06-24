#!/usr/bin/env bash
set -euo pipefail

target="${1:-}"
if [[ -z "$target" || ! -e "$target" ]]; then
  echo "usage: $0 <skill_dir_or_run_dir>" >&2
  exit 2
fi

fail=0
say_fail() {
  echo "$*" >&2
  fail=1
}

scan_text() {
  local pattern="$1"
  local label="$2"
  local matches
  if command -v rg >/dev/null 2>&1; then
    matches="$(rg -n --hidden \
      --glob '!tools/bin/**' \
      --glob '!*.png' --glob '!*.jpg' --glob '!*.jpeg' --glob '!*.gif' \
      --glob '!*.zip' --glob '!*.tar' --glob '!*.tar.gz' \
      --glob '!.git/**' \
      --glob '!**/scripts/check_forbidden_terms.sh' \
      --glob '!**/scripts/check_run_artifact.sh' \
      -i -- "$pattern" "$target" || true)"
  else
    matches="$(grep -RInE -- "$pattern" "$target" 2>/dev/null | grep -Ev '(^|/)\\.git/|(^|/)scripts/check_forbidden_terms.sh|(^|/)scripts/check_run_artifact.sh' || true)"
  fi
  matches="$(printf '%s\n' "$matches" | grep -Ev 'scan for `\?{2,}`|broken encoding \(`\?{2,}`\)|becomes `\?{2,}`|no broken encoding|mojibake|encoding damage|public package scans|parse JSON|find HTML|reject external runtime assets|checks generated JSON/HTML artifacts|敏感词/乱码扫描|不得暴露私有鉴权|公开文档不得暴露私有鉴权' || true)"
  if [[ -n "$matches" ]]; then
    echo "$matches" >&2
    say_fail "$label"
  fi
}

scan_text '\?\?\?|�|Ã|Â|ä¸|乱码|mojibake' "encoding damage or mojibake found"
scan_text 'sk-[A-Za-z0-9_-]{12,}|sk_live_[A-Za-z0-9_-]+|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9_]{20,}|AIza[0-9A-Za-z_-]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}' "secret-like token found"
scan_text '(Authorization|Bearer|x-api-key|api[_ -]?key|access[_ -]?token|refresh[_ -]?token|client[_ -]?secret|password|passwd|private[_ -]?key)\s*[:=]\s*["'\'']?[^"'\''[:space:]]{8,}' "credential assignment found"
scan_text '-----BEGIN (RSA |OPENSSH |EC |DSA |)PRIVATE KEY-----' "private key block found"
scan_text '(/home/[A-Za-z0-9._/-]+|/Users/[A-Za-z0-9._/-]+|[A-Za-z]:\\[A-Za-z0-9._\\ -]+)' "local absolute path found"
scan_text 'https?://(localhost|127\.0\.0\.1|10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.|[^[:space:]/]*(internal|private|corp|backend|admin)[^[:space:]/]*)' "internal/private URL found"
scan_text '内部鉴权|计费网关|私有账号|真实密钥|供应商账号|后台token|后端token|扣费逻辑' "private implementation wording found"

if [[ -d "$target/tools/bin" ]] && command -v strings >/dev/null 2>&1 && command -v rg >/dev/null 2>&1; then
  while IFS= read -r -d '' bin; do
    if strings -a "$bin" | rg -i '(/home/|/Users/|[A-Za-z]:\\|https?://[^[:space:]]*(internal|private|corp|backend|admin)|Authorization:|Bearer |x-api-key|AKIA|ghp_|AIza|xox[baprs]-)' >/tmp/agent_meta_skill_strings_match 2>/dev/null; then
      echo "$bin" >&2
      cat /tmp/agent_meta_skill_strings_match >&2
      say_fail "binary contains private-looking strings"
    fi
  done < <(find "$target/tools/bin" -maxdepth 1 -type f -print0)
  rm -f /tmp/agent_meta_skill_strings_match
fi

if [[ "$fail" != "0" ]]; then
  exit 1
fi

echo "ok: no forbidden terms found in $target"
