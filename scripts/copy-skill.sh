#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/copy-skill.sh [target-root] [options]

Options:
  -s, --skill NAME       Skill name to copy. Can be repeated.
                         Defaults to all top-level skill directories.
  -t, --tools LIST       Comma-separated tools: codex,claudecode,opencode,all.
                         Defaults to all.
  -f, --force            Replace an existing copied skill directory or symlink.
  -h, --help             Show this help.

Examples:
  scripts/copy-skill.sh "$HOME"
  scripts/copy-skill.sh "$HOME" --skill commit-messages
  scripts/copy-skill.sh "$HOME" --tools codex,opencode --force
USAGE
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"

target_root="."
tools="all"
force="false"
skills=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--skill)
      [[ $# -ge 2 ]] || die "--skill requires a value"
      skills+=("$2")
      shift 2
      ;;
    -t|--tools)
      [[ $# -ge 2 ]] || die "--tools requires a value"
      tools="$2"
      shift 2
      ;;
    -f|--force)
      force="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      die "unknown option: $1"
      ;;
    *)
      target_root="$1"
      shift
      ;;
  esac
done

[[ -d "$target_root" ]] || die "target root does not exist: $target_root"
target_root="$(cd -- "$target_root" && pwd)"

if [[ ${#skills[@]} -eq 0 ]]; then
  for skill_md in "$repo_root"/*/SKILL.md; do
    [[ -f "$skill_md" ]] || continue
    skills+=("$(basename -- "$(dirname -- "$skill_md")")")
  done
fi

[[ ${#skills[@]} -gt 0 ]] || die "no skills found in $repo_root"

expanded_tools=()
IFS=',' read -ra requested_tools <<< "$tools"
for tool in "${requested_tools[@]}"; do
  case "$tool" in
    all)
      expanded_tools+=(codex claudecode opencode)
      ;;
    codex|claudecode|claude|claude-code|opencode)
      expanded_tools+=("$tool")
      ;;
    "")
      ;;
    *)
      die "unsupported tool: $tool"
      ;;
  esac
done

[[ ${#expanded_tools[@]} -gt 0 ]] || die "no tools selected"

install_dir_for_tool() {
  case "$1" in
    codex)
      printf '.codex/skills\n'
      ;;
    claudecode|claude|claude-code)
      printf '.claude/skills\n'
      ;;
    opencode)
      printf '.opencode/skills\n'
      ;;
    *)
      return 1
      ;;
  esac
}

copy_skill() {
  local skill="$1"
  local tool="$2"
  local source_path="$repo_root/$skill"
  local relative_install_dir install_dir dest_path tmp_path

  [[ -f "$source_path/SKILL.md" ]] || die "skill not found: $skill"

  relative_install_dir="$(install_dir_for_tool "$tool")"
  install_dir="$target_root/$relative_install_dir"
  dest_path="$install_dir/$skill"
  tmp_path="$install_dir/.${skill}.tmp.$$"

  mkdir -p "$install_dir"

  if [[ -e "$dest_path" || -L "$dest_path" ]]; then
    if [[ "$force" != "true" ]]; then
      die "$dest_path already exists. Re-run with --force to replace it."
    fi
    rm -rf -- "$dest_path"
  fi

  rm -rf -- "$tmp_path"
  cp -R "$source_path" "$tmp_path"
  mv "$tmp_path" "$dest_path"
  printf 'copied: %s -> %s\n' "$source_path" "$dest_path"
}

for skill in "${skills[@]}"; do
  for tool in "${expanded_tools[@]}"; do
    copy_skill "$skill" "$tool"
  done
done
