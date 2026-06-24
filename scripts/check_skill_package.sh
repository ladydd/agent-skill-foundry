#!/usr/bin/env bash
set -euo pipefail

skill_dir="${1:-}"
cli_prefix="${2:-}"
if [[ -z "$skill_dir" || ! -d "$skill_dir" ]]; then
  echo "usage: $0 <skill_dir> [cli-prefix]" >&2
  exit 2
fi

fail=0
say_fail() {
  echo "$*" >&2
  fail=1
}

for path in SKILL.md INSTRUCTIONS.md references; do
  if [[ ! -e "$skill_dir/$path" ]]; then
    say_fail "missing: $path"
  fi
done

deny_names=(
  .env
  go-cli
  cli-src
  dist
  build
  node_modules
  __pycache__
)
for name in "${deny_names[@]}"; do
  if [[ -e "$skill_dir/$name" ]]; then
    say_fail "forbidden in public skill package: $name"
  fi
done

if find "$skill_dir" -mindepth 1 \( \
  -name 'run_*' -o \
  -name '*_20[0-9][0-9][0-9][0-9][0-9][0-9]_*' -o \
  -name '*.zip' -o \
  -name '*.tar' -o \
  -name '*.tar.gz' -o \
  -name '*.log' -o \
  -name '.DS_Store' \
\) -print -quit | grep -q .; then
  find "$skill_dir" -mindepth 1 \( \
    -name 'run_*' -o \
    -name '*_20[0-9][0-9][0-9][0-9][0-9][0-9]_*' -o \
    -name '*.zip' -o \
    -name '*.tar' -o \
    -name '*.tar.gz' -o \
    -name '*.log' -o \
    -name '.DS_Store' \
  \) -print >&2
  say_fail "release package contains run output, archive, log, or system artifact"
fi

if [[ -d "$skill_dir/tools/bin" && -z "$cli_prefix" ]]; then
  echo "warning: tools/bin exists but no cli-prefix supplied; binary exact-set checks were skipped" >&2
fi

if [[ -n "$cli_prefix" ]]; then
  bin_dir="$skill_dir/tools/bin"
  if [[ ! -d "$bin_dir" ]]; then
    say_fail "missing: tools/bin"
  else
    expected=(
      "$cli_prefix-darwin-amd64"
      "$cli_prefix-darwin-arm64"
      "$cli_prefix-linux-amd64"
      "$cli_prefix-windows-amd64.exe"
    )
    expected_sorted="$(printf '%s\n' "${expected[@]}" | sort)"
    actual_sorted="$(find "$bin_dir" -maxdepth 1 -mindepth 1 -type f -exec basename {} \; | sort)"
    if [[ "$actual_sorted" != "$expected_sorted" ]]; then
      echo "expected tools/bin files:" >&2
      echo "$expected_sorted" >&2
      echo "actual tools/bin files:" >&2
      echo "$actual_sorted" >&2
      say_fail "tools/bin must contain exactly the four platform binaries"
    fi
    if find "$bin_dir" -maxdepth 1 -mindepth 1 -type d -print -quit | grep -q .; then
      find "$bin_dir" -maxdepth 1 -mindepth 1 -type d -print >&2
      say_fail "tools/bin contains directories"
    fi
    for file in "${expected[@]}"; do
      if [[ ! -f "$bin_dir/$file" ]]; then
        say_fail "missing binary: tools/bin/$file"
      elif [[ "$file" != *windows* && ! -x "$bin_dir/$file" ]]; then
        say_fail "binary is not executable: tools/bin/$file"
      elif [[ ! -s "$bin_dir/$file" ]]; then
        say_fail "binary is empty: tools/bin/$file"
      fi
    done

    if command -v file >/dev/null 2>&1; then
      for file in "${expected[@]}"; do
        [[ -f "$bin_dir/$file" ]] || continue
        desc="$(file "$bin_dir/$file")"
        case "$file" in
          *linux-amd64)
            [[ "$desc" == *"ELF"* && "$desc" == *"x86-64"* ]] || say_fail "wrong binary type for $file: $desc"
            ;;
          *darwin-amd64)
            [[ "$desc" == *"Mach-O"* && ( "$desc" == *"x86_64"* || "$desc" == *"x86-64"* ) ]] || say_fail "wrong binary type for $file: $desc"
            ;;
          *darwin-arm64)
            [[ "$desc" == *"Mach-O"* && "$desc" == *"arm64"* ]] || say_fail "wrong binary type for $file: $desc"
            ;;
          *windows-amd64.exe)
            [[ "$desc" == *"PE32+"* && ( "$desc" == *"x86-64"* || "$desc" == *"x86_64"* ) ]] || say_fail "wrong binary type for $file: $desc"
            ;;
        esac
      done
    fi
  fi
fi

if [[ "$fail" != "0" ]]; then
  exit 1
fi

echo "ok: package shape looks valid"
